From: Nebojsa Miljanovic <neb@alcatel-lucent.com>
Subject: Re: SO_REUSEADDR not allowing server and client to use same port
Date: Thu, 28 Feb 2008 14:44:15 -0600
Message-ID: <47C71D1F.80005@alcatel-lucent.com>
References: <47C6FA2A.5030302@alcatel-lucent.com> <20080228203616.GD8953@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"Kittlitz, Edward (Ned)" <nkittlitz@alcatel-lucent.com>,
	asweeney@alcatel-lucent.com,
	"Polhemus, William (Bart)" <bpolhemus@alcatel-lucent.com>,
	netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763621AbYB1Uon@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Willy,
I agree. That would also work nicely. I do wish SO_REUSEPORT was available.

But, I am amazed that this issue has a long history (I've seen posts from 1999)
and that there was no progress with it.

Thanks,
Neb


On 2/28/2008 2:36 PM, Willy Tarreau wrote:
> [cc'd netdev]
> 
> On Thu, Feb 28, 2008 at 12:15:06PM -0600, Nebojsa Miljanovic wrote:
> 
>>Hello all,
>>I have seen similar complaints about this issue before in the list archive, but
>>I have not seen any resolution. So, I am posting the question again in hope of
>>getting some replies.
>>
>>Currently, Linux does not allow reuse of same local port for both TCP server and
>>TCP client. I understand that there may be a need to prevent two servers from
>>binding to the same local port, but having 1 server and 1 outgoing client use it
>>should be allowed. Other Unix like operating systems do allow it.
> 
> 
> I've been encountering the need for SO_REUSEPORT as implemented on some BSD
> for instance. It allows any process to explicitly permit another one to bind
> to the same IP:port provided that it also sets its socket with SO_REUSEPORT.
> This is a real requirement when you need to restart a service without any
> service disruption.
> 
> In the end, I've written a trivial patch for 2.4 (but most likely 2.6 would
> use nearly the same one). I noticed that the conflict detection logic already
> distinguished between 3 cases: sk->reuse==0, sk->reuse==1, sk->reuse >1.
> sk->reuse was set to 1 with SO_REUSEADDR. I simply had to make SO_REUSEPORT
> do sk->reuse |= 2 to get everything working as expected.
> 
> I don't know yet if it is as easy to do in 2.6, but if there is a possible
> acceptance of including this useful feature into mainline, I can try to
> work a patch (possibly cleaner than my existing one for 2.4).
> 
> Regards,
> Willy
> 
