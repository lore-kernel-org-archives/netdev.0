From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: Fw: issues with SO_PRIORITY and IP_TOS
Date: Tue, 04 Nov 2003 12:02:45 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FA7DBB5.1090500@nortelnetworks.com>
References: <200311041233.PAA15518@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, jmorris@redhat.com, hadi@znyx.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:


>>Currently, for me to send a packet with IP precedence bits set to a 
>>nonzero value *and* vlan priority set to the same value, I have to do 
>>the following:
>>
>>int opt = PRIORITY << 5;
>>setsockopt(mysocks[i], SOL_IP, IP_TOS, &opt, sizeof(opt));
>>opt = PRIORITY;
>>setsockopt(mysocks[i], SOL_SOCKET, SO_PRIORITY, &opt, sizeof(opt));

> Hmm.. This is kinda nice. IP_TOS sets real TOS bits without any funny
> shifts and masks, but with some reasonable access control, SO_PRIORITY
> sets priority. TOS and PRIORITY are not related.

If that were the case, I'd be happy.  However, when you set the TOS bits 
(which really sets the whole 8-bit field, rather than just the 4 TOS 
bits), the kernel also sets the socket priority but only uses the TOS 
bits to do so.  If we're going to set the whole 8-bit field, wouldn't it 
make sense to use the priority bits to set the priority?  Or even leave 
the socket priority totally alone?

This is why I proposed the IP_DSCP option which would have sane handling 
of the socket priority when setting the DSCP value.

> I do not even think that IP_DSCP makes sense in diffserv environment.
> Packets are marked according to DS rules, not according to desire
> of particular user.

If root wants to send out a packet with particular DSCP settings, 
doesn't it make sense to make that option available?  It's a field in 
the IP packet header, we should be able to set it with an IP option.


Chris



-- 
Chris Friesen                    | MailStop: 043/33/F10
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
