From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next] tcp: provide SYN headers for passive
 connections
Date: Mon, 04 May 2015 08:12:10 -0700
Message-ID: <1430752330.3711.180.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430502237-5619-1-git-send-email-emunson@akamai.com>
	 <1430505777.3711.135.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S34ftz_wDoPwcJg_cMQu4QtnBJF-=d+gF5ieTA=d=r31-Q@mail.gmail.com>
	 <20150501201417.GB6113@akamai.com>
	 <1430511800.3711.138.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150501202908.GC6113@akamai.com>
	 <1430512894.3711.140.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1430714086.3711.165.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CABrhC0nmsfAyHgJX8zEBDBVfFN=2qXKy7cO0Kbp9R9UCeEYowg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric B Munson <emunson-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org>,
	Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: John Heffner <johnwheffner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CABrhC0nmsfAyHgJX8zEBDBVfFN=2qXKy7cO0Kbp9R9UCeEYowg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-05-04 at 10:41 -0400, John Heffner wrote:

> Nice idea, seems handy.  But a couple (somewhat related) questions:
> 
> * Other than convenience, are there reasons not use an existing, more
> general-purpose and portable mechanism like pcap?  (Permissions, I
> guess?)

Very hard to synchronize when say you have 32 listeners sharing a single
port (SO_REUSEPORT), and receive one million SYN per second (when my TCP
listener scaling work is finished).

libpcap here would be a serious bottleneck, even with a clever FANIN
support on the af_packet sockets, considering use of multiqueue NIC.

> * Are there conditions where, for security purposes, you don't want an
> application to have access to the raw SYNs?

Not that we are aware of : We restrict the access to IP + TCP headers,
for the passive part. All information that is available there was
provided by the remote peer on a 'open way' anyway.

Thanks.
