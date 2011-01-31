From: Roland Dreier <roland@kernel.org>
Subject: Re: Oops with ipsec vpn on latest 2.6.38-rc2+ kernel
Date: Mon, 31 Jan 2011 00:42:36 -0800
Message-ID: <AANLkTiknwEmgg+32=VNu8+bRbUP6aC8at6eJtLeUSRFg@mail.gmail.com>
References: <AANLkTi=OTfax3CFzD9xBHbjV0RRB7aNEpHD0p9nm1cOB@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog109.obsmtp.com ([74.125.245.86]:33453 "HELO
	na3sys010aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754190Ab1AaIui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 03:50:38 -0500
Received: by ywk9 with SMTP id 9so2137781ywk.17
        for <netdev@vger.kernel.org>; Mon, 31 Jan 2011 00:50:36 -0800 (PST)
In-Reply-To: <AANLkTi=OTfax3CFzD9xBHbjV0RRB7aNEpHD0p9nm1cOB@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> With an up-to-date kernel (head is 1f0324caefd3), I'm seeing the following oops
> when I try to send traffic (I think it's my first name server query)
> through an ipsec VPN (set up with the shrew client

So I bisected this down to d33e455337ea ("net: Abstract default MTU metric
calculation behind an accessor.") and indeed I verified that the call to
dst_mtu() in ip_append_data() is calling a NULL dst->ops->default_mtu

Haven't debugged which dst this is or why it's missing that method yet...

 - R.
