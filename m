From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] ss: Tell user about -EOPNOTSUPP for SOCK_DESTROY
Date: Mon, 16 May 2016 20:24:03 -0600
Message-ID: <3d0fd83a-fa88-8ceb-a44d-237f5a005eb4@cumulusnetworks.com>
References: <1463442791-2399-1-git-send-email-dsa@cumulusnetworks.com>
 <1463442791-2399-2-git-send-email-dsa@cumulusnetworks.com>
 <CAKD1Yr08Zm55=oxMWUxL5-=D-gt4Hg5nfKSH7KRi38Ki=VyqcQ@mail.gmail.com>
 <bf9bfd17-9b96-dac4-a429-5470a44aa66c@cumulusnetworks.com>
 <CAKD1Yr2tzVATZLYV86KmvPvAohW2-49J+6Wc6PuP+xmLwBz9Qg@mail.gmail.com>
 <39db6a27-9dfa-1c9a-2699-2f01a0e64a66@cumulusnetworks.com>
 <CAKD1Yr3itVp4UgWF1uFSVRKzQm_vaLEQT=FnfBNjUJJVTj2Z+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lorenzo Colitti <lorenzo@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:35652 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754615AbcEQCYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 22:24:08 -0400
Received: by mail-io0-f171.google.com with SMTP id d62so6506007iof.2
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 19:24:08 -0700 (PDT)
In-Reply-To: <CAKD1Yr3itVp4UgWF1uFSVRKzQm_vaLEQT=FnfBNjUJJVTj2Z+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/16/16 8:04 PM, Lorenzo Colitti wrote:
> Given that the filter can specify a number of sockets, some of which
> can and some of which can't be closed, and that whether a given socket
> can be closed is only known at the time we attempt to close it, there
> is a choice between two bad outcomes:
>
> 1. Users try to use "ss -K" with a kernel that doesn't support it, and
> get confused about why it does nothing and doesn't print an error
> message.
> 2. Users use "ss -K" with a kernel that does support it, and get
> irritated by seeing one error message per TCP_TIME_WAIT socket, UDP
> socket, etc.

As I mentioned we can print the unsupported once or per socket matched 
and with the socket params. e.g.,

+               } else if (errno == EOPNOTSUPP) {
+                       printf("Operation not supported for:\n");
+                       inet_show_sock(h, diag_arg->f, diag_arg->protocol);

Actively suppressing all error messages is just wrong. I get the 
flooding issue so I'm fine with just printing it once.
