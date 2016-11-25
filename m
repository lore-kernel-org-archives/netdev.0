From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Fri, 25 Nov 2016 06:31:18 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2010562B1@RTITMBSV03.realtek.com.tw>
References: <95fa9f67-3af6-6749-0e2b-c95406486f7d@pobox.com>
 <baf5246d-9d8a-4029-6823-350ed561fd33@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB201055ED8@RTITMBSV03.realtek.com.tw>
 <20161124.112152.692025478489876693.davem@davemloft.net>
 <23e0c132-8844-0a34-3e0b-e412f76493ba@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        nic_swsd <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Mark Lord <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <23e0c132-8844-0a34-3e0b-e412f76493ba-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Content-Language: zh-TW
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Mark Lord [mailto:mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org]
> Sent: Friday, November 25, 2016 12:44 AM
[...]
> The bad data in this case is ASCII:
> 
>          "SRC=m3400:/ TARGET=/m340"
> 
> This data is what is seen in /run/mount/utab, a file that is read/written over NFS on
> each boot.
> 
>          "SRC=m3400:/ TARGET=/m3400 ROOT=/
> ATTRS=nolock,addr=192.168.8.1\n"
> 
> But how does this ASCII data end up at offset zero of the rx buffer??
> Not possible -- this isn't even stale data, because only an rx_desc could
> be at that offset in that buffer.
> 
> So even if this were a platform memory coherency issue, one should still
> never see ASCII data at the beginning of an rx buffer.  The driver NEVER
> writes anything to the rx buffers.  Only the USB hardware ever does.
> 
> And only the r8152 dongle/driver exhibits this issue.
> Other USB dongles do not.  They *might* still have such issues,
> but because they use software checksums, the bad packets are caught/rejected.

Do you test it by rebooting? Maybe you could try a patch
commit 93fe9b183840 ("r8152: reset the bmu"). However, it should
only occur for the first urb buffer after rx is reset. I don't
think you would reset the rx frequently, so the situation seems
to be different.

Best Regards,
Hayes

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
