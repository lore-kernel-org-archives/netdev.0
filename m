From: Elad Lahav <elahav@cs.uwaterloo.ca>
Subject: Re: [PATCH] Implementation of the sendgroup() system call
Date: Mon, 04 May 2009 09:44:31 -0400
Message-ID: <20090504094431.174745mb0jhhm3s4@www.nexusmail.uwaterloo.ca>
References: <49FE47A1.7070700@uwaterloo.ca>
	<87eiv5ibnd.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Elad Lahav <elahav@uwaterloo.ca>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755966AbZEDNpr@vger.kernel.org>
In-Reply-To: <87eiv5ibnd.fsf@basil.nowhere.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> My guess it's more the copies than the calls?
It's a factor of both. This is why we also created the sendgroup()  
implementation that uses a tight loop of in-kernel calls to sendmsg()  
as a means for evaluating the cost of mode switches. It is definitely  
not negligible (exact numbers depend on the size of the group and the  
size of the payload, of course).

> It sounds like you want sendfile() for UDP.
Do you mean by having a per-recipient sendfile() call for the same  
file? Leaving the cost of the system call aside, this solution does  
not work well with the kind of real-time data that we've been working  
with (live streaming, online games). You would have to write the  
payload to the file as it is being generated and call sendfile() after  
each such write.

--Elad
