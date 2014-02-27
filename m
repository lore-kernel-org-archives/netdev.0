From: "Jan Beulich" <JBeulich@suse.com>
Subject: RE: [PATCH net-next] consolidate duplicate code is
 skb_checksum_setup() helpers
Date: Thu, 27 Feb 2014 12:20:15 +0000
Message-ID: <530F3B8F020000780011FD33@nat28.tlf.novell.com>
References: <530F0DBC020000780011FC30@nat28.tlf.novell.com>
 <9AAE0902D5BC7E449B7C8E4E778ABCD025D340@AMSPEX01CL01.citrite.net>
 <530F3468020000780011FCFB@nat28.tlf.novell.com>
 <9AAE0902D5BC7E449B7C8E4E778ABCD025D4FD@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Eric Dumazet" <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Paul Durrant" <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:58422 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904AbaB0MUD convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Thu, 27 Feb 2014 07:20:03 -0500
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD025D4FD@AMSPEX01CL01.citrite.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 27.02.14 at 13:00, Paul Durrant <Paul.Durrant@citrix.com> wrote:
>>  -----Original Message-----
>> From: Jan Beulich [mailto:JBeulich@suse.com]
>> Sent: 27 February 2014 11:50
>> To: Paul Durrant
>> Cc: davem@davemloft.net; Eric Dumazet; netdev@vger.kernel.org 
>> Subject: RE: [PATCH net-next] consolidate duplicate code is
>> skb_checksum_setup() helpers
>> 
>> >>> On 27.02.14 at 11:57, Paul Durrant <Paul.Durrant@citrix.com> wrote:
>> >>  -----Original Message-----
>> >> From: Jan Beulich [mailto:JBeulich@suse.com]
>> >> Sent: 27 February 2014 09:05
>> >> To: netdev@vger.kernel.org 
>> >> Cc: Paul Durrant; davem@davemloft.net; Eric Dumazet
>> >> Subject: [PATCH net-next] consolidate duplicate code is
>> >> skb_checksum_setup() helpers
>> >>
>> >> Realizing that the skb_maybe_pull_tail() calls in the IP-protocol
>> >> specific portions of both helpers are terminal ones (i.e. no further
>> >> pulls are expected), their maximum size to be pulled can be made match
>> >> their minimal size needed, thus making the code identical and hence
>> >> possible to be moved into another helper.
>> >
>> > There is a difference in the case of an IPv4 TCP packet with options. With
>> > your patch it will only get pulled up as far as the base header so there may
>> > need to be another pull for options parsing.
>> 
>> Don't the options start right after the IP header, before the TCP
>> or UDP one? In which case the pull covers them.
>> 
> 
> *IP* options do, TCP options are immediately after the TCP header (hence the 
> TCP header length field). UDP doesn't have options.

Oh, right, of course. But then again - is the maximum length of
TCP options different between v4 and v6? If not, that limit
should be used here rather than the more generic (and version
dependent) IP limit.

And iiuc the UDP case could remain as is.

Jan
