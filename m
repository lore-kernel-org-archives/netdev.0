From: Neal Cardwell <ncardwell-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next] tcp: provide SYN headers for passive connections
Date: Mon, 4 May 2015 10:02:42 -0400
Message-ID: <CADVnQymBB+H+v8SeC1+4QY7+tpVz1heVd2r4f=d6xFq8v2SyTQ@mail.gmail.com>
References: <1430502237-5619-1-git-send-email-emunson@akamai.com>
	<1430505777.3711.135.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S34ftz_wDoPwcJg_cMQu4QtnBJF-=d+gF5ieTA=d=r31-Q@mail.gmail.com>
	<20150501201417.GB6113@akamai.com>
	<1430511800.3711.138.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150501202908.GC6113@akamai.com>
	<1430512894.3711.140.camel@edumazet-glaptop2.roam.corp.google.com>
	<1430714086.3711.165.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric B Munson <emunson-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org>,
	Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1430714086.3711.165.camel-XN9IlZ5yJG9HTL0Zs8A6p/gx64E7kk8eUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, May 4, 2015 at 12:34 AM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> From: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>
> This patch allows a server application to get the TCP SYN headers for
> its passive connections.  This is useful if the server is doing
> fingerprinting of clients based on SYN packet contents.
>
> Two socket options are added: TCP_SAVE_SYN and TCP_SAVED_SYN.
>
> The first is used on a socket to enable saving the SYN headers
> for child connections. This can be set before or after the listen()
> call.
>
> The latter is used to retrieve the SYN headers for passive connections,
> if the parent listener has enabled TCP_SAVE_SYN.
>
> TCP_SAVED_SYN is read once, it frees the saved SYN headers.
>
> The data returned in TCP_SAVED_SYN are network (IPv4/IPv6) and TCP
> headers.
>
> Original patch was written by Tom Herbert, I changed it to not hold
> a full skb (and associated dst and conntracking reference).
>
> We have used such patch for about 3 years at Google.
>
> Signed-off-by: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> ---

Acked-by: Neal Cardwell <ncardwell-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Tested-by: Neal Cardwell <ncardwell-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

The code looks good to me, and I re-ran the test I wrote (and which I
see Eric posted), and double-checked that it passes on net-next with
this patch applied.

Personally I like the socket option names from this patch.
TCP_SAVE_SYN means "Please save SYN headers for child sockets of this
listener". And TCP_SAVED_SYN means "Please give me the saved SYN for
this accepted child."

Thanks, Eric!

neal
