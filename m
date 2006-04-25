From: John Heffner <jheffner@psc.edu>
Subject: Re: tune back idle cwnd closing?
Date: Tue, 25 Apr 2006 10:27:37 -0400
Message-ID: <444E31D9.1010705@psc.edu>
References: <44493980.1040708@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:44512 "EHLO mailer2.psc.edu")
	by vger.kernel.org with ESMTP id S932233AbWDYO1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2006 10:27:42 -0400
To: Zach Brown <zach.brown@oracle.com>
In-Reply-To: <44493980.1040708@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zach Brown wrote:
> My apologies if this is a FAQ, I couldn't find it in the archives.
> 
> We have some dudes who are syncing large amounts of data across a
> dedicated long fat pipe at somewhat irregular intervals that are, sadly,
> longer than the rto.  They feel the pain of having to reopen the window
> between transmissions.
> 
> Is there room for a compromise tunable that would be less aggressive
> about closing cwnd during idle periods but which wouldn't violate the
> spirit of 2861?  No one wants broken TCP here.
> 
> They mention that Solaris has the tcp_slow_start_after_idle tunable and
> that it helps their situation.  I mention that only as a data point, I
> wouldn't be foolish enough to try and use the presence of something in
> Solaris as justification :)


Yours is the first complaint of this kind I recall seeing, but I've 
expected for a while someone would have this type of problem.  RFC2861 
seems conceptually nice at first, but there are a few things about it 
that bother me.  One thing in particular is that a naturally bursty 
application (like yours) will actually perform better by padding its 
connection with junk data whenever it doesn't have real data to send. 
Or equivalently, it's punished for not sending data when it doesn't need 
to.  I also think it may not do much good when there are connections 
with significantly different RTTs.

Given that RFC2681 is Experimental (and I'm not aware of any current 
efforts in the IETF to push it to the standard track), IHMO it would not 
be inappropriate to make this behavior controlled via sysctl.

Thanks,
   -John
