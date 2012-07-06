From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP transmit performance regression
Date: Fri, 06 Jul 2012 06:58:34 +0200
Message-ID: <1341550714.3265.44.camel@edumazet-glaptop>
References: <CACVXFVNM-Db=_793SVfRj+nxGtNG0pRFrwc_F9TGbU0FfES63A@mail.gmail.com>
	 <1341474192.2583.3299.camel@edumazet-glaptop>
	 <CACVXFVNxcdEYd-KmkUe9=8+x_9s-ZVuoM=FfZ=QXa7w_qRiTnw@mail.gmail.com>
	 <1341477192.2583.3415.camel@edumazet-glaptop>
	 <CACVXFVPTXB7t=zwkm+HTgDaF3bA02bzff_52S+UAr51PfpvpCg@mail.gmail.com>
	 <1341481760.2583.3579.camel@edumazet-glaptop>
	 <CACVXFVNZ=64+=w1ZapXeXq7oYz0OBbBRLuH8rNSeDHyz7zGOZw@mail.gmail.com>
	 <1341484919.2583.3688.camel@edumazet-glaptop>
	 <CACVXFVPksMd8CGZWEGBXBXB5NZCg3QOZreOLavkV-Z2pjE-M_A@mail.gmail.com>
	 <1341500196.2583.4222.camel@edumazet-glaptop>
	 <CACVXFVMgwbz1fDC=_9dhVUZ_btiO3fNdFiuXm-7gMXFUAMtmsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:47912 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004Ab2GFE6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 00:58:41 -0400
Received: by eeit10 with SMTP id t10so3460414eei.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 21:58:40 -0700 (PDT)
In-Reply-To: <CACVXFVMgwbz1fDC=_9dhVUZ_btiO3fNdFiuXm-7gMXFUAMtmsw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-06 at 08:45 +0800, Ming Lei wrote:

> Unfortunately, the patch still hasn't any improvement on the transmit
> performance of beagle-xm.

Ah yes, I need to change usbnet as well to be able to fully recycle the
big skbs allocated in turbo mode.

Right now they are constantly allocated/freed and this sucks if SLAB
wants to check poison bytes in debug mode.

Thanks
