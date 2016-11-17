From: Yishai Hadas <yishaih-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: mlx4 BUG_ON in probe path
Date: Thu, 17 Nov 2016 12:22:44 +0200
Message-ID: <efdb87e8-cac0-f45b-7f6f-122f053fe366@dev.mellanox.co.il>
References: <20161116182527.GC26600@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Johannes Thumshirn <jthumshirn-l3A5Bk7waGM@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bjorn Helgaas <helgaas-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161116182527.GC26600-1RhO1Y9PlrlHTL0Zs8A6p5iNqAH0jzoTYJqu5kTmcBRl57MIdRCFDg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/16/2016 8:25 PM, Bjorn Helgaas wrote:
> Hi Yishai,
>
> Johannes has been working on an mlx4 initialization problem on an
> IBM x3850 X6.  The underlying problem is a PCI core issue -- we're
> setting RCB in the Mellanox device, which means it thinks it can
> generate 128-byte Completions, even though the Root Port above it
> can't handle them.  That issue is
> https://bugzilla.kernel.org/show_bug.cgi?id=187781
>
> The machine crashed when this happened, apparently not because of any
> error reported via AER, but because mlx4 contains a BUG_ON, probably
> the one in mlx4_enter_error_state().
>
> That one happens if pci_channel_offline() returns false.  Is this
> telling us about a problem in PCI error handling, or is it just a case
> where mlx4 isn't as smart as it could be?

Yes, we expect at that step a problem/bug in the PCI layer that should 
be fixed (e.g. reporting online but really is offline, etc.), can you 
please evaluate and confirm that ?


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
