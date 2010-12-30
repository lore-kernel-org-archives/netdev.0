From: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v2 00/12] make rpc_pipefs be mountable multiple time
Date: Thu, 30 Dec 2010 03:10:20 -0600
Message-ID: <4D1C4C7C.6050606@parallels.com>
References: <1293628470-28386-1-git-send-email-kas@openvz.org> <AANLkTi=AXz21wDeE1vPVD-6cEtj6faXN9x09eHDCsTkB@mail.gmail.com> <20101230085139.GA29697@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	<linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20101230085139.GA29697-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/30/2010 02:51 AM, Kirill A. Shutemov wrote:
> On Wed, Dec 29, 2010 at 08:13:50PM -0600, Rob Landley wrote:
>> On Wed, Dec 29, 2010 at 7:14 AM, Kirill A. Shutemov<kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>  wrote:
>>>
>>> Prepare nfs/sunrpc stack to use multiple instances of rpc_pipefs.
>>> Only for client for now.
>>
>> What would a test case for this look like?  (Is there some way to tell
>> an nfs mount to use a specific instance of rpc_pipefs or something?)
>
> You can create a new instance of rpc_pipefs using 'newinstance'
> mountoption.
>
> Then you can specify which rpc_pipefs to use with 'rpcmount' mountoption
> of nfs mount. If none specifed, '/var/lib/nfs/rpc_pipefs' uses by default.

That path is as the process performing the mount sees it?

> If no rpcmount mountoption, no rpc_pipefs was found at
> '/var/lib/nfs/rpc_pipefs' and we are in init's mount namespace, we use
> init_rpc_pipefs.

It's the "we are in init's mount namespace" that I was wondering about.

So if I naievely chroot, nfs mount stops working the way it did before I 
chrooted unless I do an extra setup step?

I'm actually poking at getting nfs mount working in LXC containers with 
different network routing (mostly study so far, it took me a couple 
weeks just to get lxc to work for me and now I'm trying to wrap my head 
around Linux's NFS implementation), so I'm very interested in this...

Rob
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
