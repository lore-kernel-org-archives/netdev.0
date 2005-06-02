From: Baruch Even <baruch@ev-en.org>
Subject: Re: 2.6.12-rc5-mm2: "bic unavailable using TCP reno" messages
Date: Thu, 02 Jun 2005 14:58:17 +0100
Message-ID: <429F1079.5070701@ev-en.org>
References: <20050601022824.33c8206e.akpm@osdl.org> <20050602121511.GE4992@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, shemminger@osdl.org,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261425AbVFBN6c@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050602121511.GE4992@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> On Wed, Jun 01, 2005 at 02:28:24AM -0700, Andrew Morton wrote:
> 
>>...
>>Changes since 2.6.12-rc5-mm1:
>>...
>>+tcp-tcp_infra.patch
>>...
>> Steve Hemminger's TCP enhancements.
>>...
> 
> 
> I said "no" to CONFIG_TCP_CONG_BIC, and now my syslog is full of messages
>    kernel: bic unavailable using TCP reno
> 
> I have no problem with such a message being shown once - but once should 
> be enough.  

The best solution for this would be to check the available protocols at
setup time and not at connection creation time. This would also provide
a better feedback to the user, since he will either see that what he set
was taken, or it wasn't.

In the current mechanism you can set the protocol to 'foo' and it will
show back as 'foo'. You'll get complaints only once a connection is
attempted with this protocol.

It does mean some extra work in the sysctl stage, but it's better IMO to
do it there rather than at connection setup time.

Baruch
