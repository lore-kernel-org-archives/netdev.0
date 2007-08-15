From: Bruce Cole <bacole@gmail.com>
Subject: Re: Realtek r8168 slow outbound transfer - potential fix/workaround
Date: Tue, 14 Aug 2007 22:46:52 -0700
Message-ID: <46C2934C.9060907@gmail.com>
References: <25536.1187071305@iinet.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bacole@gmail.com
To: gundy@iinet.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.187]:55974 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065AbXHOFuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 01:50:44 -0400
Received: by rv-out-0910.google.com with SMTP id k20so1643183rvb
        for <netdev@vger.kernel.org>; Tue, 14 Aug 2007 22:50:43 -0700 (PDT)
In-Reply-To: <25536.1187071305@iinet.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gundy@iinet.net.au wrote:
> Bruce,
>
> I settled on using ndelay(10) rather than udelay(25) in the end..  
> it's probably a bit safer & less likely to cause problems with higher 
> throughputs.
Yes, I saw that you later recommended the change but opted to try it the 
way you tested first. 
>
> When I was diagnosing the problem I used 2 machines.  One machine was 
> running Samba on linux (the 'problem' machine), and one was a windows 
> XP machine.
Likewise, tho I also tested vista.
>
> I used tcpdump to capture the traffic on the Samba machine, and used 
> wireshark to capture the traffic on the windows machine.  What i found 
> was happening was that samba was attempting to send two packets to the 
> windows machine in quick succession (ie. something in the order of a 
> 1/10,000th or less of a second apart).  Although both packets showed 
> up in the tcpdump output from the linux machine, only the first packet 
> appeared to be making it to the windows machine.   Because the second 
> packet was 'lost', it had to be retried after a delay and this is what 
> was causing the abysmal performance.
>
> The reasoning behind my patch was that I figured the TxPoll register 
> wasn't being given enough time to reset itself after sending the 
> previous packet.   I may or may not have been correct with that 
> assumption, but as you noticed the delay does seem to make it behave a 
> bit better.
Disclaimer: I haven't seen the definition for that register so I'm just 
guessing here.
I suppose the danger is that your fix may just be changing the timing 
around such that the time-dependent bug does not occur as readily, yet a 
bug remains.  Does anyone have the programming spec for this chip from 
realtek, or are we all just forced to guess :)?
>
> I understand that Francios came up with a similar patch that he said 
> also worked, and that he thought was a bit more robust than my 
> method.  I'd check with him on what the status of that particular 
> patch is.
Thanks, I don't see that patch in 2.6.23-rc3 but I'll try Francios' 
recommendations first and if that doesn't work I'll test out things with 
the shorter ndelay().

