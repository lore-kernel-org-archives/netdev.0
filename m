From: Patrick McHardy <kaber@trash.net>
Subject: Re: Kernel 2.6.13 breaks libpcap (and tcpdump).
Date: Sun, 04 Sep 2005 19:31:26 +0200
Message-ID: <431B2F6E.9070401@trash.net>
References: <E1EBpkT-0001RP-00@gondolin.me.apana.org.au> <431B2985.1060502@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, jmcgowan@inch.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932081AbVIDRbc@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <431B2985.1060502@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Herbert Xu wrote:
> 
>> We aren't handling the reading of specific fields like the IP protocol
>> field correctly.  This patch should make it work again.
> 
> 
> I can't spot the problem, could you give me a hint?

Never mind, I got it, we never fall through to the second switch
statement anymore. I think we could simply break when load_pointer
returns NULL. The switch statement will fall through to the default
case and return 0 for all cases but 0 > k >= SKF_AD_OFF.
