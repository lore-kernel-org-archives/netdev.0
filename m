From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][IPV6] fixed authentication error with TCP
Date: Mon, 18 Aug 2003 03:11:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818031148.5c9ab656.davem@redhat.com>
References: <200308172329.DAA14889@dub.inr.ac.ru>
	<Pine.LNX.4.44.0308181029560.18400-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, kazunori@miyazawa.org, netdev@oss.sgi.com,
   usagi@linux-ipv6.org, latten@austin.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.44.0308181029560.18400-200000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Aug 2003 10:45:41 +0300 (EEST)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> The attached patch reverts to the old ip6_dst_lookup() interface and and
> makes tcp_ipv6.c use that instead.

I applied your patch with a small change, I made it so
that *dst is set to NULL in every case that ip6_dst_lookup()
returned an error.

In particular, there were some error paths still in tcp_ipv6.c
that would dst_release() in the error path which only works if
dst is set to NULL in ip6_dst_lookup() error cases.
