From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Strange TCP SACK behaviour in Linux TCP
Date: Tue, 18 Jul 2006 15:56:43 -0400
Message-ID: <20060718155643.78eddf52@localhost.localdomain>
References: <44BD0A5F.4090001@kom.aau.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:25047 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932372AbWGRT5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 15:57:25 -0400
To: Oumer Teyeb <oumer@kom.aau.dk>
In-Reply-To: <44BD0A5F.4090001@kom.aau.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 18 Jul 2006 18:20:47 +0200
Oumer Teyeb <oumer@kom.aau.dk> wrote:

> Hello Guys,
> 
> I have some questions regarding TCP SACK implementation in Linux .
> As I am a subscriber, could you please cc the reply to me? thanks!
> 
> 
> I am doing these experiments to find out the impact of reordering. So I 
> have different TCP versions (newReno, SACK, FACk, DSACK, FRTO,....) as 
> implemented in Linux. and I am trying their combination to see how they 
> behave. What struck me was that when I dont use timestamps, introducing 
> SACK increases the download time but decreases the total number of 
> retransmissions.
> When timestamps is used, SACK leads to an increase in both the download 
> time and the retransmissions.
> 
> So I looked further into the results, and what I found was that when 
> SACK  is used, the retransmissions seem to happen earlier .
> at www.kom.auc.dk/~oumer/first_transmission_times.pdf
> you can find the pic of cdf of the time when the first TCP 
> retransmission occured for the four combinations of SACK and timestamps 
> after hundrends of downloads of a 100K file for the different conditions 
> under network reordering...
> 
> This explains the reason why the download time increases with SACK, 
> because the earlier we go into fast recovery the longer the time we 
> spend on congestion avoidance, and the longer the download time....
> 
> ...but I couldnt figure out why the retransmissions occur earlier for 
> SACK than no SACK TCP. As far as I know, for both SACK and non SACK 
> cases, we need three (or more according to the setting) duplicate ACKs 
> to enter the fast retransmission /recovery state.... which would have 
> resulted in the same behaviour to the first occurance of a 
> retransmission..... or is there some undocumented enhancment in Linux 
> TCP when using SACK that makes it enter fast retransmit earlier... the 
> ony explanation I could imagine is something like this
> 
> non SACK case
> =============
> 1 2 3 4 5 6 7 8 9 10..... were sent and 2 was reorderd....and assume we 
> are using delayed ACKs...and we get a triple duplicate ACK after pkt#8 
> is received. (i.e 3&4--first duplicate ACK, 5&6..second duplicate ACK 
> and 7&8...third duplicate ACK.....)...
> 
> so if SACK behaved like this...
> 
> 3&4 SACKEd.... 2 packets out of order received
> 5&6 SACKEd....4 packets out of order received.... start fast 
> retransmission....as reorderd is greater than 3.... (this is true when 
> it comes to marking packets as lost during fast recovery, but is it true 
> als for the first retransmission?)
> 
> .. any ideas why this is happening???
> 
> 
> Thanks in advance,
> Oumer

Could you post some short tcpdump snapshot summaries to netdev@vger.kernel.org?
