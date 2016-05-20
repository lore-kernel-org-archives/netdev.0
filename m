From: Shrikrishna Khare <skhare@vmware.com>
Subject: Re: [PATCH net-next 5/7] Driver: Vmxnet3: Add support for get_coalesce,
 set_coalesce ethtool operations
Date: Fri, 20 May 2016 11:46:33 -0700 (PDT)
Message-ID: <alpine.DEB.2.10.1605201114420.14228@shri-linux.eng.vmware.com>
References: <1462576336-83513-1-git-send-email-skhare@vmware.com>   <1462576336-83513-6-git-send-email-skhare@vmware.com>  <1462622686.19332.33.camel@decadent.org.uk>  <alpine.DEB.2.10.1605081335140.13942@shri-linux.eng.vmware.com>
 <1462753040.9308.11.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="554307656-1241437366-1463769994=:14228"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com, Keyong Sun <sunk@vmware.com>,
	Manoj Tammali <tammalim@vmware.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462753040.9308.11.camel@decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--554307656-1241437366-1463769994=:14228
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT



On Sun, 8 May 2016, Ben Hutchings wrote:

> > Would a patch that maps 0 to 'no coalescing' be acceptable? That is:
> > 
> > rx-usecs = 0 -> coalescing disabled.
> > rx-usecs = 1 -> default (chosen by the device).
> > rx-usecs = 2 -> adaptive coalescing.
> > rx-usecs = 3 -> static coalescing.
> 
> I still don't like it much.  For the 3 special values (0 isn't really
> special):
> 
> 1 = default: When the driver sets the virtual device to this mode, can it then read back what the actual settings are, or are they hidden?  If it can, then userland can also read the defaults and explicitly return to them later.  But I do see the usefulness of an explicit request to reset to defaults.
> 
> 2 = adaptive coalescing: There are already fields to request adaptive coalescing; you should support them.
> 
> 3 = static coalescing: I don't understand what this means.

static refers to the number of packets to batch before raising an 
interrupt - which maps to existing tx_max_coaleced_frames.

Have sent out v2 of the patch that no longer uses special values of 
rx-usecs to distinguish between the coalescing modes. Existing 
ethtool_coalesce fields are used as appropriate instead.

In v2, driver can no longer issue "revert to defaults" command 
(think such a mechanism might be useful addition but belongs to ethtool 
framework).


Thanks,
Shri
--554307656-1241437366-1463769994=:14228--
