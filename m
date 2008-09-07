From: "Rami Rosen" <roszenrami@gmail.com>
Subject: Re: add/delete VLANs programatically
Date: Sun, 7 Sep 2008 13:58:20 +0300
Message-ID: <b25312890809070358t6a4b7296x778c2de01412ab6e@mail.gmail.com>
References: <20080907071246.GA12270@mtls03>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Eli Cohen" <eli@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:39560 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752973AbYIGK6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2008 06:58:20 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1139934wfd.4
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2008 03:58:20 -0700 (PDT)
In-Reply-To: <20080907071246.GA12270@mtls03>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
  -It seems to me that it is possible.

  - If  you look at the ordinary way in which user space add/deletes
VLAN, you will see that this is performed by ioctls (SIOCSIFVLAN for
adding /removing with ADD_VLAN_CMD or DEL_VLAN_CMD).
- It is in performed by user space vconfig - VLAN (802.1q)
configuration program.

- When looking  at how these IOCTLs are handled in the kernel, you
will see that this is done by  vlan_ioctl_handler() in net/8021q/vlan.c.

 -If you look there, you will see that eventually adding a vlan is
done in the kernel by
register_vlan_device(net_device, VLAN ID);
end deleing a vlan is done in the kernel by calling
unregister_vlan_dev(net_device)

So it seems to me possible, though I did not try it.

Regards,
Rami Rosen




On Sun, Sep 7, 2008 at 10:12 AM, Eli Cohen <eli@dev.mellanox.co.il> wrote:
> Hi,
> I need to find a way to manipulate VLANs from a kernel module;
> specifically, I need to add and remove VLANs. Is that possible at all?
> How?
>
> Thanks,
> Eli
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
