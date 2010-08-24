From: Marc Aurele La France <tsi@ualberta.ca>
Subject: Re: RFC: MTU for serving NFS on Infiniband
Date: Tue, 24 Aug 2010 09:14:54 -0600 (Mountain Daylight Time)
Message-ID: <alpine.WNT.2.00.1008240856170.2000@cluij.ucs.ualberta.ca>
References: <alpine.LNX.2.00.1008230842290.9325@abcyxhiz.aict.ualberta.ca> <20100823080543.319143e3@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100823080543.319143e3@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Aug 2010, Stephen Hemminger wrote:
> On Mon, 23 Aug 2010 08:44:37 -0600 (MDT)
> Marc Aurele La France <tsi@ualberta.ca> wrote:
>> In regrouping for my next tack at this, I noticed that all stack traces go
>> through ip_append_data().  This would be ipv6_append_data() in the IPv6 case.
>> A _very_ rough draft that would have ip_append_data() temporarily drop down
>> to a smaller fake MTU follows ...

> Why doesn't NFS generate page size fragments?  Does Infiniband or your
> device not support this?  Any thing that requires higher order allocation
> is going to unstable under load.  Let's fix the cause not the apply bandaid
> solution to the symptom.

>From what I can tell, IP fragmentation is done centrally.

The MTU is a device attribute, yes.  But, here, it is ip_append_data(), 
not NFS nor the device driver, whose responsibility it is to break up the 
payload into fragments, either by itself or using any facility supported 
by the adapter.  What I'm saying is that there's no reason to require all 
fragments, except the last, to be MTU-sized.  The RFCs I've looked at 
allow them to be shorter which can be used to advantage when MTU-sized 
fragments cannot be allocated in a memory fragmentation scenario, instead 
of reporting an error.

Marc.

+----------------------------------+----------------------------------+
|  Marc Aurele La France           |  work:   1-780-492-9310          |
|  Academic Information and        |  fax:    1-780-492-1729          |
|    Communications Technologies   |  email:  tsi@ualberta.ca         |
|  352 General Services Building   +----------------------------------+
|  University of Alberta           |                                  |
|  Edmonton, Alberta               |    Standard disclaimers apply    |
|  T6G 2H1                         |                                  |
|  CANADA                          |                                  |
+----------------------------------+----------------------------------+
