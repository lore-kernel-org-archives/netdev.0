From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] New Patch: Implementation for IPv6 MIB:ipv6AddressTable
Date: Fri, 10 Oct 2003 00:04:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031010000413.7935be3c.davem@redhat.com>
References: <OF4B7AD7E2.5CA239A1-ON87256DB9.0067C527@us.ibm.com>
	<20031008130016.559b8047.davem@redhat.com>
	<200310081706.09485.mashirle@us.ibm.com>
	<200310091317.35164.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Shirley Ma <mashirle@us.ibm.com>
In-Reply-To: <200310091317.35164.mashirle@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 9 Oct 2003 13:17:35 -0700
Shirley Ma <mashirle@us.ibm.com> wrote:

> Which one do you think is better.
> 
> This one is too much math.
> 
> ci.cstamp = (__u32)(TIME_DELTA(ifa->cstamp, INITIAL_JIFFIES) / HZ * 100
> 		  + TIME_DELTA(ifa->cstamp, INITIAL_JIFFIES) % HZ * 100 / HZ);
> ci.tstamp = (__u32)(TIME_DELTA(ifa->tstamp, INITIAL_JIFFIES) / HZ * 100
> 		  + TIME_DELTA(ifa->tstamp, INITIAL_JIFFIES) % HZ * 100 / HZ);

Why are you using jiffies for timestamps?  I guess these values
are measured "since bootup" or something like that?

Anyways, I prefer the "too much math" because 1) it isn't a lot of
math, most of these things are constants which make the expressions
easy to compute 2) it's only done when someone asks for the information.
