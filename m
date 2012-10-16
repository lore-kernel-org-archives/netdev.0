From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: bpf filter : support for vlan tag
Date: Tue, 16 Oct 2012 13:00:43 +0200
Message-ID: <CAD6jFUTn98+i_0eh6gc-CYgVXHNLbZdZmV6==mL+duFM-oNRmg@mail.gmail.com>
References: <CAOxq_8MqMatY2+GA6+mHjj5V=Xe7Y8BmuX4r6cz5nChU5C1Vzw@mail.gmail.com>
	<1350369998.3954.563.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ani Sinha <ani@aristanetworks.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58304 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753558Ab2JPLAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 07:00:50 -0400
Received: from [78.46.4.229] (helo=sslproxy03.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TO4tF-00040C-JK
	for netdev@vger.kernel.org; Tue, 16 Oct 2012 13:00:49 +0200
Received: from [74.125.83.46] (helo=mail-ee0-f46.google.com)
	by sslproxy03.your-server.de with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TO4tC-000296-HJ
	for netdev@vger.kernel.org; Tue, 16 Oct 2012 13:00:46 +0200
Received: by mail-ee0-f46.google.com with SMTP id b15so3422394eek.19
        for <netdev@vger.kernel.org>; Tue, 16 Oct 2012 04:00:43 -0700 (PDT)
In-Reply-To: <1350369998.3954.563.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 16, 2012 at 8:46 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2012-10-15 at 19:10 -0700, Ani Sinha wrote:
>> Hi :
>>
>> I was looking at the kernel side implementation of the BPF filter. I
>> do not see any code that supports filtering of packets based on
>> provided vlan tag information from the skbuff. This will make it
>> impossible to provide any filter to tcpdump that will filter packets
>> based on the tag information if libpcap uses the kernel filter.
>>
>> Any help will be much appreciated.
>
> Right, we need a basic support, using a new ancillary definition.
>
> Is the following patch enough to address your need, or do you also need
> access to vlan_tx_tag_present() ?

I like this patch, it's especially useful to speed up processing for
packet analyzers. vlan_tx_tag_present() might also be good to have if
this doesn't waste to much room for future ancillary operations.
