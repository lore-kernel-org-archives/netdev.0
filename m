From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: TCP congestion graphs (2.6.19-rc4)
Date: Tue, 31 Oct 2006 16:10:07 -0800
Message-ID: <20061031161007.0fdf5c63@freekitty>
References: <20061025110207.78d38779@freekitty>
	<000701c6f885$b57aa390$4a580e98@ncsu2cc0c3fa00>
	<20061031120016.75dc4c3c@freekitty>
	<7335583a0610311525h10cf4e75x42e421d3eb6f53aa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Injong Rhee" <rhee@eos.ncsu.edu>,
	"David S. Miller" <davem@davemloft.net>,
	"Sangtae Ha" <sha2@ncsu.edu>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:65483 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1946215AbWKAAKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 19:10:18 -0500
To: "Xiaoliang (David) Wei" <davidwei79@gmail.com>
In-Reply-To: <7335583a0610311525h10cf4e75x42e421d3eb6f53aa@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 31 Oct 2006 15:25:16 -0800
"Xiaoliang (David) Wei" <davidwei79@gmail.com> wrote:

> On 10/31/06, Stephen Hemminger <shemminger@osdl.org> wrote:
> > I reran the tests, this time using my DSL line to home (80ms 1Mbit/sec).
> >         http://developer.osdl.org/shemminger/tcp/2.6.19-rc4/dsl
> >
> > The only obvious problem is Vegas looks broken.
> 
> Thanks, Stephen.
> 
> It seems that the default Vegas alpha parameter in the rc4 is 1...
> 
> I observed similar situation with the NS2Linux simulator (with 2.6.16
> code) and found that if alpha=1, delayed ack will make it broken
> (keeping cwnd very low without real congestion)
> 
> See details at http://www.cs.caltech.edu/%7Eweixl/technical/ns2linux/known_linux/index.html#vegas
> 
> (Basically alpha==1 means Vegas seeks to see a delay of about 1 packet
> worth. With delayed ack, 1 packet worth of delay is common even with
> no congestion.)
> 
> To make Vegas work, I'd suggest to raise alpha to at least 2 or 3.
> (and beta has to be at least as large as alpha.)
> 
> -David
> 

I ran with the current default:
	alpha = 1 (scaled 2)
	beta  = 3 (scaled 6)
	gamma = 1 (scaled 2)




-- 
Stephen Hemminger <shemminger@osdl.org>
