From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sock_hold and sock_put
Date: Wed, 24 Jun 2015 17:26:01 +0200
Message-ID: <1435159561.4110.14.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAGZFCEHHXbnsSoBaTUdxqwoQ75hN5BTBXJMEXp0dkwQbFSEkRw@mail.gmail.com>
	 <1435150000.4110.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAGZFCEFQju581PDF3QpyX-s8vvdxPrZTwS85CP3rTu4wUfEHBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-newbie <linux-newbie@vger.kernel.org>
To: ratheesh kannoth <ratheesh.ksz@gmail.com>
Return-path: <linux-newbie-owner@vger.kernel.org>
In-Reply-To: <CAGZFCEFQju581PDF3QpyX-s8vvdxPrZTwS85CP3rTu4wUfEHBg@mail.gmail.com>
Sender: linux-newbie-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-06-24 at 19:44 +0530, ratheesh kannoth wrote:
> On Wed, Jun 24, 2015 at 6:16 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > You misunderstood the comment.
> >
> > Comment only stated that sock_hold() must be used in contexts where
> > caller owns a reference (and will eventually release it later with
> > sock_put().
> >
> > There is nothing about having a lock here.
> 
> Thanks. I think, i did not put the question right.
> 
> I understood the comment perfectly. Suppose i need to use the
> sock_hold in some callbacks ( say netdev_notifier chain callback)
> function. How can i gurantee race won't happen at the point where i
> call sock_hold().
>  If i put the question  in another way - say kernel is doing a
> sock_put() on a socket, and at the same time  the   netdev_callback
> function( that i implemented ) is called on another core ( in smp
> machine ). and the  callback is  holding (sock_hold()) on the same
> sock.

You can not possibly use sock_hold() from the callback, unless you
already took a reference on the socket _before_ callback was called, to
make sure socket would not disappear.

Its hard to understand what you try to do here.

If you worry because socket would disappear when "kernel is doing a
sock_put()", then it means you did not take the needed extra reference
to make sure callback would access a valid socket.


--
To unsubscribe from this list: send the line "unsubscribe linux-newbie" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at http://www.linux-learn.org/faqs
