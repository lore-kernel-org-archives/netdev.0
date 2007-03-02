From: John Heffner <jheffner@psc.edu>
Subject: Re: SWS for rcvbuf < MTU
Date: Fri, 02 Mar 2007 16:16:39 -0500
Message-ID: <45E89437.3000902@psc.edu>
References: <200703021128.29208.alexandre.sidorenko@hp.com>	<20070302.112542.18305896.davem@davemloft.net>	<200703021521.58821.alexandre.sidorenko@hp.com> <20070302.123325.28790131.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexandre.sidorenko@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:55557 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965640AbXCBVQr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 16:16:47 -0500
In-Reply-To: <20070302.123325.28790131.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Alex Sidorenko <alexandre.sidorenko@hp.com>
> Date: Fri, 2 Mar 2007 15:21:58 -0500
> 
>> they told us that they use small rcvbuf to throttle bandwidth for this 
>> application. I explained it would be better to use TC for this purpose. They 
>> agreed and will probably redesign their application in the future, but they 
>> cannot do it right now. For the same reason they have to use the old 2.4.20 
>> for a while - in big companies the important production software cannot be 
>> changed quickly. 
>>
>> The fix I suggested is trivial and should have no impact the case of 
>> rcvfbuf>mtu, so I think it makes sense to include it in upstream kernel.
> 
> I have no objection to the fix, especially John's version.
> 
> I was just curious about the app, thanks for the info :)

Please don't apply the patch I sent.  I've been thinking about this a 
bit harder, and it may not fix this particular problem.  (Hard to say 
without knowing exactly what it is.)  As the comment above 
__tcp_select_window() states, we do not do full receive-side SWS 
avoidance because of header prediction.

Alex, you're right I missed that special zero-window case.  I'm still 
not quite sure I'm completely happy with this patch.  I'd like to think 
about this a little bit harder...

Thanks,
   -John
