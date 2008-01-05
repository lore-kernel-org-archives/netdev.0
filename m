From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: sparc oops in ip_fast_csum
Date: Sat, 5 Jan 2008 09:44:00 +0000
Message-ID: <20080105094400.GH27894@ZenIV.linux.org.uk>
References: <200801041837.37650.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, sparclinux@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Return-path: <sparclinux-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200801041837.37650.m.kozlowski@tuxland.pl>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 04, 2008 at 06:37:36PM +0100, Mariusz Kozlowski wrote:
> Hello,
> 
>         This comes from the Linus latest linux-2.6 tree. Randomly happened.
> Can't reproduce that. More info below.

ip_fast_csum() called from raw_send_hdrinc() from raw_sendmsg() ran through
the page boundary into unmapped page...  Bloody odd, that, seeing that
we have checked iph->ihl * 4U <= length and had done
        err = memcpy_fromiovecend((void *)iph, from, 0, length);
before the
                iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
that had triggered that crap..
