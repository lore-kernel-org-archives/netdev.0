From: Mark Doffman <mark.doffman-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
Subject: Re: [PATCH 2/4] Documentation: Document the cephroot functionality
Date: Wed, 15 Jan 2014 11:22:50 -0600
Message-ID: <52D6C3EA.50407@codethink.co.uk>
References: <1385000024-23463-1-git-send-email-mark.doffman@codethink.co.uk> <1385000024-23463-3-git-send-email-mark.doffman@codethink.co.uk> <alpine.DEB.2.00.1312062154530.1560@cobra.newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rob Taylor <rob.taylor-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sage Weil <sage-4GqslpFJ+cxBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1312062154530.1560-vIokxiIdD2AQNTJnQDzGJqxOck334EZe@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Sage,

On 12/06/2013 11:57 PM, Sage Weil wrote:
> On Wed, 20 Nov 2013, mark.doffman-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org wrote:
>> From: Rob Taylor <rob.taylor-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
>>
>> Document using the cephfs as a root device, its purpose,
>> functionality and use.
>>
>> Signed-off-by: Mark Doffman <mark.doffman-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
>> Signed-off-by: Rob Taylor <rob.taylor-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
>> Reviewed-by: Ian Molton <ian.molton-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
>> ---
>>   Documentation/filesystems/{ => ceph}/ceph.txt |  0
>>   Documentation/filesystems/ceph/cephroot.txt   | 81 +++++++++++++++++++++++++++
>>   2 files changed, 81 insertions(+)
>>   rename Documentation/filesystems/{ => ceph}/ceph.txt (100%)
>>   create mode 100644 Documentation/filesystems/ceph/cephroot.txt
>>
>> diff --git a/Documentation/filesystems/ceph.txt b/Documentation/filesystems/ceph/ceph.txt
>> similarity index 100%
>> rename from Documentation/filesystems/ceph.txt
>> rename to Documentation/filesystems/ceph/ceph.txt
>> diff --git a/Documentation/filesystems/ceph/cephroot.txt b/Documentation/filesystems/ceph/cephroot.txt
>> new file mode 100644
>> index 0000000..ae0f5bb
>> --- /dev/null
>> +++ b/Documentation/filesystems/ceph/cephroot.txt
>> @@ -0,0 +1,81 @@
>> +Mounting the root filesystem via Ceph (cephroot)
>> +===============================================
>> +
>> +Written 2013 by Rob Taylor <rob.taylor-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
>> +
>> +derived from nfsroot.txt:
>> +
>> +Written 1996 by Gero Kuhlmann <gero-TuicA7gkpRym5h6znurzUg@public.gmane.org>
>> +Updated 1997 by Martin Mares <mj-jyMamyUUXNJG4ohzP4jBZS1Fcj925eT/@public.gmane.org>
>> +Updated 2006 by Nico Schottelius <nico-kernel-nfsroot-xuaVFQXs+5hIG4jRRZ66WA@public.gmane.org>
>> +Updated 2006 by Horms <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
>> +
>> +
>> +
>> +In order to use a diskless system, such as an X-terminal or printer server
>> +for example, it is necessary for the root filesystem to be present on a
>> +non-disk device. This may be an initramfs (see Documentation/filesystems/
>> +ramfs-rootfs-initramfs.txt), a ramdisk (see Documentation/initrd.txt), a
>> +filesystem mounted via NFS or a filesystem mounted via Ceph. The following
>> +text describes on how to use Ceph for the root filesystem.
>> +
>> +For the rest of this text 'client' means the diskless system, and 'server'
>> +means the Ceph server.
>> +
>> +
>> +1.) Enabling cephroot capabilities
>> +    -----------------------------
>> +
>> +In order to use cephroot, CEPH_FS needs to be selected as
>> +built-in during configuration. Once this has been selected, the cephroot
>> +option will become available, which should also be selected.
>> +
>> +In the networking options, kernel level autoconfiguration can be selected,
>> +along with the types of autoconfiguration to support. Selecting all of
>> +DHCP, BOOTP and RARP is safe.
>> +
>> +
>> +2.) Kernel command line
>> +    -------------------
>> +
>> +When the kernel has been loaded by a boot loader (see below) it needs to be
>> +told what root fs device to use. And in the case of cephroot, where to find
>> +both the server and the name of the directory on the server to mount as root.
>> +This can be established using the following kernel command line parameters:
>> +
>> +root=/dev/ceph
>> +
>> +This is necessary to enable the pseudo-Ceph-device. Note that it's not a
>> +real device but just a synonym to tell the kernel to use Ceph instead of
>> +a real device.
>> +
>> +cephroot=<monaddr>:/[<subdir>],<ceph-opts>
>> +
>> +  <monaddr>     Monitor address. Each takes the form host[:port]. If the port
>> +		is not specified, the Ceph default of 6789 is assumed.
>> +
>> +  <subdir>	A subdirectory subdir may be specified if a subset of the file
>> +		system is to be mounted
>> +
>> +  <ceph-opts>	Standard Ceph options. All options are separated by commas.
>> +		See Documentation/filesystems/ceph/ceph.txt for options and
>> +		their defaults.
>
> Maybe there is an existing convention here, but: it seems like it would be
> simpler to do something like
>
>   cephroot=<ip[:<port>][,...]>:/[<subdir>]
>
> i.e., the existing syntax used by mount, that (among other things) can
> also include a port, or be a list of mon ips, so that the parsing code
> can be re-used.  Then,
>
>   cephopts=<ceph-opts>
>
> Hopefully this would avoid the parsing in root.c and make things behave
> more consistently with respect to how mount(8) is used?

This would make things more consistent with mount, and easier! The 
reason to keep it the way it is is for consistency with NFS and DHCP 
option 17.

NFS concatenates the options in DHCP root-path (option 17) with the ones 
placed on the kernel command line. We could separate out the device and 
path strings from the options, but they would still be merged together 
in the DHCP string. Some parsing would still be required to split the 
DHCP string and merge with command line options. I'd prefer to keep them 
together on the command line also, just to have things stay similar to NFS.

Thanks

Mark

>
> sage
>
>> +
>> +4.) References
>> +    ----------
>> +
>> +
>> +5.) Credits
>> +    -------
>> +
>> +  cephroot was derived from nfsroot by Rob Taylor <rob.taylor-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
>> +  and Mark Doffman <mark.doffman-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
>> +
>> +  The nfsroot code in the kernel and the RARP support have been written
>> +  by Gero Kuhlmann <gero-TuicA7gkpRym5h6znurzUg@public.gmane.org>.
>> +
>> +  The rest of the IP layer autoconfiguration code has been written
>> +  by Martin Mares <mj-jyMamyUUXNJG4ohzP4jBZS1Fcj925eT/@public.gmane.org>.
>> +
>> +  In order to write the initial version of nfsroot I would like to thank
>> +  Jens-Uwe Mager <jum-gG2S4stXkm6Shm5Tz/htGQ@public.gmane.org> for his help.
>> --
>> 1.8.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe ceph-devel" in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
