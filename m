From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: Re: setsockopt(IP_TOS) being privileged or distinct capability?
Date: Mon, 05 Jul 2010 21:08:05 -0600
Message-ID: <4C329E15.2000601@redfish-solutions.com>
References: <4C2F7A55.5090700@redfish-solutions.com> <2md4g7-3s3.ln1@chipmunk.wormnet.eu> <4C2FC2C8.8080203@redfish-solutions.com> <20100703234813.GJ24655@chipmunk> <4C321EAF.9000508@redfish-solutions.com> <20100706020734.GA2972@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Clouter <alex@digriz.org.uk>, netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:40755 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757084Ab0GFDIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 23:08:16 -0400
In-Reply-To: <20100706020734.GA2972@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/5/10 8:07 PM, Hagen Paul Pfeifer wrote:
> * Philip Prindeville | 2010-07-05 12:04:31 [-0600]:
>
>    
>> I understand that.  That's part of the reason that I've submitted
>> patches for APR, Apache, Thunderbird, Firefox, Proftpd, Curl, wget,
>> etc.  There is pressure within certain technical groups to get ISP's
>> to voluntarily implement RFC-4594... that's the carrot.  The stick
>> being FCC heavy-handed regulation of the ISP's if they don't.
>>      
> Where is the _real_ advantage if setsockopt(IP_TOS) where a privileged
> operation? At the end the user/service is still required to set his service
> class, but this time with CAP_NET_ADMIN. Do you think that Service
> Providers/Transit Providers trust (and this is the critical aspect) customers
> based on some IP flags - this is extreme unlikely. 99% of users have
> effective CAP_NET_ADMIN capabilities - and you cannot stop using them.
>    

QoS is expensive to implement, since it requires a lot more inspection 
of the packet, multiple queues, bandwidth reservation, etc.

ISP's are going to look for an excuse not to implement it.

Having it be exploited by users is another arrow in their quill to not 
implement it.

Yes, most users have admin/privileged rights on their machines, but 
don't know enough to exploit that.

Whatever makes it harder to abusively exploit QoS seems like a good 
idea.  Harder.  Not impossible.

"Stopping them" was never the objective.

> Service Providers/Transit Providers will trust customers who pays more and
> then they will accept their DIFFSERV suggestion signaled via IP DSCP. All
> other customers will be treated normal, with zeroed DSCP. It makes no sense
> for ISP's to shift the trust aspect to the customer side.
>
> HGN
>
>
>    

Alas there's more to it than that: the movement is to make QoS be 
ubiquitous for all SLA's of broadband.

I'd argue that it makes no sense for them not to trust it:  SDP/RTP 
packets are hard to identify as such without peaking into the 
accompanying SIP conversation... which drives up the cost of their 
required infrastructure to handle QoS even more.

Besides, if I deploy a new protocol that uses RTP or leverages QoS, I'd 
have to wait for the ISP to update their network with knowledge of that 
protocol in order to handle it properly... given the glacial pace that 
at which ISP's certify and deploy software updates, configuration 
changes, etc. I don't want to have to wait months or years for them to 
play catch-up.

What's more, if I'm running SIP over TLS over TCP, they can't peek into 
the stream anyway to figure out what UDP ports I'm using for SDP.

So I can sacrifice control, privacy, or timeliness... or they can simply 
trust my QoS markings.

But what's the downside of their trusting my markings, anyway?

Let's say that I have 7mb/s DSL, and with that standard base profile 
comes 240kb/s EF policing, 512kb/s AF4x, etc.  Further let's suppose 
that I exceed my SLA: they could either downgrade the excess to the next 
lowest bin, or discard it... Hence I'm highly incentivized to remain 
within my agreed SLA envelope.


