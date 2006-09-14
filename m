From: Dan Williams <dcbw@redhat.com>
Subject: Re: [d80211] some issues regarding iwconfig parameters sequence
Date: Thu, 14 Sep 2006 09:34:44 -0400
Message-ID: <1158240884.2634.4.camel@localhost.localdomain>
References: <4508717B.8060403@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jkm@devicescape.com,
	johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36783 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1750718AbWINNdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2006 09:33:21 -0400
To: mabbas <mabbas@linux.intel.com>
In-Reply-To: <4508717B.8060403@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-09-13 at 14:00 -0700, mabbas wrote:
> Hi
> I have some problem connecting if I don't follow some parameters 
> sequence in iwconfig command for example if I issues the following
> # iwconfig wlan0 essid test  ap xx:xx:xx:xx:xx:xx
> #iwconfif wlan0 channel 9

Any reason you don't stick all the commands on one iwconfig line, or why
you don't do the channel first?  Some operations with WEXT are
undefined, and I think command ordering is one of them.  However, I
believe that the card/driver should be keeping all the attributes set,
and any time an attribute changes that would break a current association
or operation (like locking the channel), then the card/driver should be
restarting association/auth with the new attribute set.

> in d80211 if essid and bssid set it will start authentication with 
> default channel and authentication will timeout then after the second 
> command kicks in to tune to the right channel the retry counter of 
> authentication will be at maximum and we wont authenticate, same problem 
> exist for IBSS it will start searching but once we call #iwconfif wlan0 
> channel 9 this will stop scanning and we stop IBSS searching . I 

That seems wrong; once you set the channel, d80211 should be resetting
the current assoc/auth stuff, and restarting the association with the
current parameters/attributes from scratch, but now only on channel 9.
WEXT didn't really have a good way to "package" a full set of
association/auth parameters; the commit-handler stuff kind of did that,
but if the commands got broken up then the semantics of what happened
when were pretty undefined.

Dan

> attached a patch for workaround this problem. I am not sure this is the 
> right way to fix just attached to illustrate the problem.
> Mohamed

