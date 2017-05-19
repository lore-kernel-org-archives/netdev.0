From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC V1 1/1] net: cdc_ncm: Reduce memory use when kernel memory
 low
Date: Fri, 19 May 2017 11:10:40 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFFAA5C@AcuExch.aculab.com>
References: <1494956480-6127-1-git-send-email-jim_baxter@mentor.com>
 <1494956480-6127-2-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Jim Baxter' <jim_baxter@mentor.com>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Oliver Neukum <oliver@neukum.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1494956480-6127-2-git-send-email-jim_baxter@mentor.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: linux-usb-owner@vger.kernel.org [mailto:linux-usb-owner@vger.kernel.org] On Behalf Of Jim Baxter
> Sent: 16 May 2017 18:41
> 
> The CDC-NCM driver can require large amounts of memory to create
> skb's and this can be a problem when the memory becomes fragmented.
> 
> This especially affects embedded systems that have constrained
> resources but wish to maximise the throughput of CDC-NCM with 16KiB
> NTB's.

Why is this driver copying multiple tx messages into a single skb.
Surely there are better ways to do this??

I think it is generating a 'multi-ethernet frame' URB with an
overall header for each URB and a header for each ethernet frame.

Given that the USB stack allows multiple concurrent transmits I'm
surprised that batching large ethernet frames makes much difference.

Also the USB target can't actually tell when URB that contain
multiples of the USB packet size end.
So it is possible to send a single NTB as multiple URB.
Of course, the usb_net might have other ideas.

	David
