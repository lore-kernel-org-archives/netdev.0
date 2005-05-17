From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 16:53:39 -0700
Message-ID: <428A8403.7000901@hp.com>
References: <OF16EC9302.031C4230-ON88257004.007BA491-88257004.007C8D46@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <OF16EC9302.031C4230-ON88257004.007BA491-88257004.007C8D46@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David Stevens wrote:

> 
> This assumes that you have a per-destination IP ID. If it's per-route, you
> can send 1 packet to host A, 65534 to host B through the same route, and 1 to
> host A-- wrap on the next received packet, as far as host A is concerned. 
> (even sooner, if it's using randomized ID's or a bigger-than-1 increment).

If we were actually looking at the ID's themselves, rather than the count of
datagrams received that would be correct, but someone already pointed-out that
ass-u-me-ing monotonic increasing was not a good thing, so simply count
datagrams completed/recevied on that source/dest pair instead.  Then we don't
really care about the sender's IP ID assignment policy.

If someone wants to hit that with a DoS attack, I'm still wondering if that is a
large DoS hole, (larger than existing ones with spoofing fragments) and the
extent to which it depends on whether the attacker is closer to me than the
sender or "on the other side" of the sender from me.

rick jones
