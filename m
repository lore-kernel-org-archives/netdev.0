From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [Bluez-devel] forcing SCO connection patch
Date: Wed, 27 Feb 2008 16:21:14 +0100
Message-ID: <5D9353FF-6A69-4039-9033-C0EBD1CDA756@holtmann.org>
References: <47666E1F.2000902@mizi.com>	 <a8e1da0802242330l765b8b1ava62b857baf8a5568@mail.gmail.com>	 <47C28A33.4070102@mizi.com> <a8e1da0802250155u1b7af481va203849f68d9106b@mail.gmail.com> <47C2A7FA.2060902@mizi.com> <70692DDF-93B7-447E-ABEE-3CDBD94F15F1@holtmann.org> <47C38D40.3040809@mizi.com> <B96BD3FE-F490-4AD5-9315-ECD42CE9C728@holtmann.org> <47C4C3D4.8010902@mizi.com> <2A7EF87C-1340-45D7-B457-F81799674B1E@holtmann.org> <47C555E5.2000903@mizi.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	bmidgley-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Louis JANG <louis-6CAt/Z4uMM0@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <47C555E5.2000903-6CAt/Z4uMM0@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Louis,

> When bluez tried to connect SCO channel with  
> HCI_OP_SETUP_SYNC_CONN(ESCO_LINK),
> a real connection may be connected with SCO_LINK instead of  
> ESCO_LINK when
> peer device doesn't support eSCO.  however bluez try to find  
> connection handle
> by event's link type(SCO_LINK in above case) and the valid  
> connection handle
> for this event is waiting for ESCO_LINK. so bluez can't find  
> connection handle
> and discarded the event.

using HCI_OP_SETUP_SYNC_CONN doesn't mean eSCO. It is perfectly fine  
to request SCO links via that command. The difference here is  
Bluetooth 1.1 or 1.2 and later.

> This patch is to handle different type of synchronous link is  
> estabilished
> with its request.
>
> If bluez can't find connection handle, it try to find with different
> link type again. (For the above case, if bluez can't find connection
> handle with SCO_LINK, it try to find connection handle with  
> ESCO_LINK again.)
> and update link type of this connection handle with event's link type.

Inside the kernel it is not called BlueZ :) It simply is the Bluetooth  
subsystem and in case the HCI core.

Regards

Marcel

-
To unsubscribe from this list: send the line "unsubscribe linux-bluetooth" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
