From: Baruch Even <baruch@ev-en.org>
Subject: Re: [PATCH] Too aggressive cwnd backoff
Date: Thu, 07 Apr 2005 19:14:45 +0100
Message-ID: <42557895.8040004@ev-en.org>
References: <20050407164146.GA6479@ev-en.org> <20050407101653.2cc68db1@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050407101653.2cc68db1@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Thu, 7 Apr 2005 19:41:46 +0300
> Baruch Even <baruch@ev-en.org> wrote:
>>The provided patch will set limit to tp->ssthresh. This was the original
>>behaviour in some older version of Linux.
> 
> I think this is a real problem, and was observed by Werner with umlsim.
> Don't know when it got introduced because it appears to pre-date the
> '04 work in adding Westwood, BIC, Vegas. Perhaps Alexey can shed some
> light on this.
> 
> Going back to the pre-westwood code in BK, the /2 is still there.

This wasn't there in 2.4.23 on which on the original work of H-TCP was 
done. I've encountered it in my work on the 2.6.6 version, but didn't 
understand all the implications at the time. I've re-encountered it now 
that I'm redoing the patches to 2.6.11, and it's as good a time as ever 
to resolve it.

The effect is not catastrophic, but it does mean that we leave recovery 
into slow-start like ascend of cwnd until we get to ssthresh again. It 
does mean that after recovery we inject a lot of packets to the network 
at a very fast rate.

Baruch
