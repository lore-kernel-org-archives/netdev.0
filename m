From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] getsockopt() early argument sanity checking
Date: Sun, 20 Aug 2006 20:38:34 +0200
Message-ID: <200608202038.34842.ak@suse.de>
References: <20060819230532.GA16442@openwall.com> <200608201034.43588.ak@suse.de> <20060820161602.GA20163@openwall.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <wtarreau@hera.kernel.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751141AbWHTSi5@vger.kernel.org>
To: Solar Designer <solar@openwall.com>
In-Reply-To: <20060820161602.GA20163@openwall.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 20 August 2006 18:16, Solar Designer wrote:
> On Sun, Aug 20, 2006 at 10:34:43AM +0200, Andi Kleen wrote:
> > In general I don't think it makes sense to submit stuff for 2.4 
> > that isn't in 2.6.
> 
> In general I agree, however right now I had the choice between
> submitting these changes for 2.4 first and not submitting them at all
> (at least for some months more).  I chose the former.

If there is really a length checking bug it shouldn't be that hard to fix it 
in both.


> We're on UP.  sys_getsockopt() does get_user() (due to the patch) and
> makes sure that the passed *optlen is sane.  Even if this get_user()
> sleeps, the value it returns in "len" is what's currently in memory at
> the time of the get_user() return (correct?)  Then an underlying
> *getsockopt() function does another get_user() on optlen (same address),
> without doing any other user-space data accesses or anything else that
> could sleep first.  Is it possible that this second get_user()
> invocation would sleep?  I think not since it's the same address that
> we've just read a value from, we did not leave kernel space, and we're
> on UP (so no other processor could have changed the mapping).  So the
> patch appears to be sufficient for this special case (which is not
> unlikely).
> 
> Of course, it is possible that I am wrong about some of the above;
> please correct me if so.

Nah you're right (except on a preemptible kernel which 2.4 isn't unpatched)
However if there is any other user access before the second get_user 
the race could happen again even on UP.

-Andi
