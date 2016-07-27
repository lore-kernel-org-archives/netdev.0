From: alexmcwhirter@triadic.us
Subject: Re: PROBLEM: network data corruption (bisected to e5a4b0bb803b)
Date: Wed, 27 Jul 2016 19:02:40 -0400
Message-ID: <87c4ed555bcb4229f2334f6f2bb69bcb@triadic.us>
References: <201607271032.u6RAWPcS008174@sdf.org>
 <4dbfebe8136bc963b5b51463d6887db4@triadic.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Christian Lamparter <chunkeey@googlemail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alan Curry <rlwinm@sdf.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4dbfebe8136bc963b5b51463d6887db4@triadic.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-07-27 14:04, alexmcwhirter@triadic.us wrote:
> Just to add some more information to this, the corruption seems to
> effect ssh as well.
> 
> Using a sun hme interface, occasionally upon an ssh connection it will
> refuse to authenticate a client with either password or cert
> authentication. Using wireshark to capture and decrypt the packets
> between the two machines, the data coming from the server seems good,
> but the data received by the server from the client is essentially
> garbage. Note that the client is sending valid data, but the server is
> corrupting it upon receipt. Closing the connection and starting a new
> one will remedy the login issue, but you do occasionally see
> corruption on the server side sporadically.
> 
> So far this only seems to occur on incoming data, outgoing data seems 
> fine.

Also, there is another patch the references this commit on sparc64 at 
least.

https://patchwork.kernel.org/patch/9221895/

I highly expect both my issue and OP's issue to revolve not around 
commit e5a4b0bb803b specifically, but around other code that no longer 
behaves as expected because of it.
