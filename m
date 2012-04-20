From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: RTM_NEWLINK not received by application when connecting
 multiple devices simultaneously
Date: Fri, 20 Apr 2012 09:15:59 -0700
Message-ID: <20120420091559.732541ef@nehalam.linuxnetplumber.net>
References: <CAKfDRXj+mydkzNFC8q2aE_JWHp3ie0cijC-itkm6sHLuZr98Fw@mail.gmail.com>
	<4F90208E.6070201@candelatech.com>
	<20120419075452.379f711b@s6510.linuxnetplumber.net>
	<CAKfDRXjCr0aDSDT8zN8A7_iNX6KAJwrR3NxaB8GAgz5oEiCB3w@mail.gmail.com>
	<CAKfDRXhAqFzPWAJkzhPdZGsUrtjex8uVwHBynCdvA+Zo6sjMig@mail.gmail.com>
	<20120419133635.7d816d67@nehalam.linuxnetplumber.net>
	<CAKfDRXih39RVnx1P72due=_v9-ORWf=YUfUTPKcvVbNzVuTLdw@mail.gmail.com>
	<20120420081400.67a98836@nehalam.linuxnetplumber.net>
	<CAKfDRXgd-9w_PL47OynVL3LX-Z7vG4skGOkQxOLc74=7jWBBXQ@mail.gmail.com>
	<CAKfDRXiPOj64M0oSW9Dc5F0+src3mAjKYna+UM8hwEiHEJXniQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42417 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755108Ab2DTQQH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2012 12:16:07 -0400
In-Reply-To: <CAKfDRXiPOj64M0oSW9Dc5F0+src3mAjKYna+UM8hwEiHEJXniQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Apr 2012 18:04:49 +0200
Kristian Evensen <kristian.evensen@gmail.com> wrote:

> I have uploaded a compressed version of my listener code here:
> http://pastebin.com/f1NPYGSh
> 
> The othe operations my application do related to netlink, is to
> configure the sockets. Could it be that the configuration messages
> somehow disturb the retrieval of other messages, as they all use the
> same mnl_sock? None of them requests any replies (they are all
> RTM_NEW*/NLM_F_CREATE), but I am not sure about the internal working
> of netlink.

Most applications using netlink listening have two sockets, one
for events the other for requests. The problem is that your own requests
will generate events and it is hard to tell what to expect next
the response (ACK) or the async event when using the same socket.
