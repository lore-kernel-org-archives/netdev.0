From: Werner Almesberger <werner@almesberger.net>
Subject: Re: [PATCH]: Adjust qlen when grafting in multiple qdiscs
Date: Mon, 17 Nov 2003 16:38:34 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031117163834.V1330@almesberger.net>
References: <3FB3996A.6080008@trash.net> <1069076786.1075.19.camel@jzny.localdomain> <3FB8DDE0.1070105@trash.net> <1069081153.1022.20.camel@jzny.localdomain> <3FB8F3BF.6050509@trash.net> <1069090210.1022.64.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1069090210.1022.64.camel@jzny.localdomain>; from hadi@cyberus.ca on Mon, Nov 17, 2003 at 12:30:10PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> My opinion is that since these interfaces (ex qdisc) exist they
> exist to be (ab)used. 

Stated in such a general way, that sounds dangerous ;-)

> Dsmark happens to work well with the single queue - maybe thats what
> needs to be documented as opposed to saying it deviates from a purist
> angle.

tcio, section 2, towards the end:

| Typically, each class ``owns'' one queue, but it is in principle
| also possible that several classes share the same queue or even
| that a single queue is used by all classes of the respective
| queuing discipline.

Now, I've of course only documented the status quo, and one could
argue whether this actually makes sense. But then, it works well
for dsmark, and doesn't seem to break anything else.

I'm a bit confused about what the problem is here (or if there is
one at all): if dsmark_graft is changed to adjust the statistics
(which makes perfect sense to me), I don't see a reason why either
subtracting the queue length of the former inner qdisc, or simply
setting dsmark's queue lenghth to zero wouldn't work.

Patrick, was the experiment "I've now verified experimentally the
problem also exists in dsmark" done with or without your
"sch->q.qlen -= (*old)->q.qlen;" patch ? This looks just like the
behaviour I'd expect your patch to fix, no ?

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina     werner@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
