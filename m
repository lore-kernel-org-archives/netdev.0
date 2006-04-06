From: David Daney <ddaney@avtrex.com>
Subject: Re: Broadcast ARP packets on link local addresses (Version2).
Date: Thu, 06 Apr 2006 09:17:58 -0700
Message-ID: <44353F36.9070404@avtrex.com>
References: <17460.13568.175877.44476@dl2.hq2.avtrex.com> <priv$efbe06144502$2d51735f79@200604.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pgf@foxharp.boston.ma.us, freek@macfreek.nl
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751265AbWDFQUy@vger.kernel.org>
To: Janos Farkas <chexum+dev@gmail.com>
In-Reply-To: <priv$efbe06144502$2d51735f79@200604.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Janos Farkas wrote:
> On 2006-04-05 at 14:22:08, David Daney wrote:
> 
>>The changes in this version are that it tests the source IP address
>>instead of the destination.  The test now matches the test described
>>in the RFC.  Also a small cleanup as suggested by Herbert Xu.
>>
>>Some comments on the first version of the patch suggested that I do
>>'X' instead.  Where 'X' was behavior different than that REQUIRED by
>>the RFC (the RFC's always seem to capitalize the word 'required').
>>
>>The reason that I implemented the behavior required by the RFC is so
>>that a device running the kernel can pass compliance tests that
>>mandate RFC compliance.
> 
> 
> Sorry for chiming in this late in the discussion, but...  Shouldn't it
> be more correct to not depend on the ip address of the used network,
> but to use the "scope" parameter of the given address?
> 

RFC 3927 specifies the Ethernet arp broadcast behavior for only 
169.254.0.0/16.  Presumably you could set the scope parameter to local 
for addresses outside of that range or even for protocols other than 
Ethernet.  Since broadcasting ARP packets usually adversely effects 
usable network bandwidth, we should probably only do it where it is 
absolutely required.  The overhead of testing the value required by the 
RFC is quite low (3 machine instructions on i686 is the size of the 
entire patch), so using some proxy like the scope parameter would not 
even be a performance win.

David Daney
