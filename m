From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP partial write
Date: Mon, 15 Jun 2009 10:09:29 -0700
Message-ID: <4A368049.7080903@hp.com>
References: <394b5e260906141252g56d4275k185230f724b842ac@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Paul Martin <srucnoc@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:14073 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570AbZFORJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 13:09:28 -0400
In-Reply-To: <394b5e260906141252g56d4275k185230f724b842ac@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Martin wrote:
> Is it possible that a (non-blocking) TCP write(2) will write a number
> of bytes not multiple of the machine word size? i.e., could a write
> request for 4 bytes return 2?

Yes.

> Also is this an OS-dependent behavior or there is a spec for it? (I
> could find atomic guarantees for pipes and datagram sockets but not
> for TCP)

TCP is a byte-stream. It sends and receives a stream of bytes.  You should/must 
assume that when you do a non-blocking write, it will take any number of the 
bytes you offer from 0 to however many bytes you give it.  And you should/must 
assume that at the other end, your recv/read calls will return with between 0 and 
however many bytes you ask of them, with 0 meaning the remote has said it has 
nothing left to give.

rick jones
