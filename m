From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v8 04/11] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Wed, 13 Jul 2016 11:27:23 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4F6ED7@AcuExch.aculab.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
 <1468309894-26258-5-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	"Jesper Dangaard Brouer" <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: 'Brenden Blanco' <bblanco@plumgrid.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.192]:62248 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978AbcGMLbe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 07:31:34 -0400
In-Reply-To: <1468309894-26258-5-git-send-email-bblanco@plumgrid.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brenden Blanco
> Sent: 12 July 2016 08:51
> Add support for the BPF_PROG_TYPE_XDP hook in mlx4 driver.
> 
> In tc/socket bpf programs, helpers linearize skb fragments as needed
> when the program touches the packet data. However, in the pursuit of
> speed, XDP programs will not be allowed to use these slower functions,
> especially if it involves allocating an skb.
> 
> Therefore, disallow MTU settings that would produce a multi-fragment
> packet that XDP programs would fail to access. Future enhancements could
> be done to increase the allowable MTU.

Maybe I'm misunderstanding what is going on here...
But what has the MTU to do with how skb are fragmented?

If the skb come from a reasonably written USB ethernet interface they could
easily have arbitrary fragment boundaries (the frames get packed into USB
buffers).

Outbound skb can also have fragments depending on how they are generated.

	David
