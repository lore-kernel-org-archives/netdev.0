From: Sridhar Samudrala <samudrala.sridhar@gmail.com>
Subject: Re: [PATCH net] vxlan: revert per-vxlan port
Date: Thu, 23 May 2013 15:35:57 -0700
Message-ID: <519E99CD.1030500@gmail.com>
References: <20130520103017.054ae605@nehalam.linuxnetplumber.net>	<OFECE722DE.3DBEE821-ON85257B71.00610478-85257B71.006456B5@us.ibm.com> <20130520113000.0057ce90@nehalam.linuxnetplumber.net>	<20130522.150830.1305371698781503084.davem@davemloft.net> <OFB688A387.A3698315-ON85257B73.007C1B7B-85257B73.00800294@us.ibm.com>	<20130522173954.7f75f62d@nehalam.linuxnetplumber.net> <OF0BD0286F.81969B78-ON85257B74.00097DBA-85257B74.000C5443@us.ibm.com>	<20130523100854.6c9749d6@nehalam.linuxnetplumber.net> <OFCF66B423.CF0815E9-ON85257B74.0062F5C7-85257B74.0067134F@us.ibm.com> <20130523121804.6b7450a3@nehalam.linuxnetplumber.net> <OFD1F52E5E.B02C16A0-ON85257B74.006AF452-85257B74.006E6AF1@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:54847 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759752Ab3EWWf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 18:35:58 -0400
In-Reply-To: <OFD1F52E5E.B02C16A0-ON85257B74.006AF452-85257B74.006E6AF1@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/23/2013 1:06 PM, David Stevens wrote:
> Stephen Hemminger <stephen@networkplumber.org> wrote on 05/23/2013
> 03:18:04 PM:
>
>   
>> With the patch davem already included, the dstport is enough
>> to add additional listener.
>          If you're saying that using the dstport changes the
> listen port, or adds another listen port, then I think that
> behaviour is wrong and should be reverted.
I agree that using 'dstport' option to also create a socket and binding 
to that port for
receives is confusing. As the name suggests, it should only be used as a 
default dst
port for fdb entries.

>          An admin should be able to specify the source and destination
> ports independently of each other. If dstport has a side-effect that
> is unrelated to changing the destination port, that's what I'd call
> "confusing."
>          IMHO, "port" should change the listen port (only) and "dstport"
> should change the send port (only). And yes, both of those should allow
> multiple ports, and destinations. So, binding should be a list of
> the form: "[IP:]port[,[IP:]port]*" and destinations should be the same
> as in the fdb, allowing multiple destinations and different ports, and
> different vni's. It should be simply a "default" fdb entry in all
> respects.
Currently 'port' option takes 2 values that indicate the range of ports 
that can be used as
source port when sending vxlan packets.

So we don't have a good way to specify listening port when creating a 
vxlan device using
the existing options.

It may be a good idea to revert dstport in linux-3.10 and  multiple 
listening ports patch in
net-next and re-implement them with 2 different options that can take a 
list of ports/addresses
as David suggested.

Thanks
Sridhar
