From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH]: Adjust qlen when grafting in multiple qdiscs
Date: 17 Nov 2003 09:59:13 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1069081153.1022.20.camel@jzny.localdomain>
References: <3FB3996A.6080008@trash.net>
	 <1069076786.1075.19.camel@jzny.localdomain>  <3FB8DDE0.1070105@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <3FB8DDE0.1070105@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Patrick,

It doesnt make sense to have more than one queue in Dsmark (used as a
place holder/work queue while DSCP remarking). 
If reset() is already setting the length to 0 then it is not useful
to set it to anything else (it may actually become a -ve number).
I would suggest you use some of the examples in
iproute2/examples/diffserv to test things out (for all your changes -
the dsmark change was staring at me in the face - i didnt pay attention
to the rest).

cheers,
jamal

On Mon, 2003-11-17 at 09:40, Patrick McHardy wrote:
> Hi Jamal,
> 
> I've tested tbf and prio changes before and after. Unfortunately I've 
> never used dsmark so I didn't test this part. I did try to make sure
> my changes make sense, and I still don't see why this wouldn't be
> correct. dsmark increments sch->q.qlen in enqueue, so it needs to
> adjust it in dsmark_graft if the old queue is non-empty. If this is
> wrong, please enlighten me so I can fix my patch.
> 
> Best regards,
> Patrick
> 
> 
> jamal wrote:
> 
> >Did you test some of this stuff or just did a mass-edit? I havent paid
> >attention to all the details, but what would decrementing sch->q.qlen on
> >grafting mean on a dsmark? 
> >
> >cheers,
> >jamal
> >
> >  
> >
> 
> 
> 
