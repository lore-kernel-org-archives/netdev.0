From: denys@visp.net.lb
Subject: Re: 40k+ outbound connections and bind() problem
Date: Wed, 26 Jan 2011 14:35:29 +0200
Message-ID: <9e62acde19ef75f3f77468cd81ed7ffd@visp.net.lb>
References: <8cdb2dde69120a8668b31e2050916493@visp.net.lb>
 <AANLkTikSvf8bNK2_eHg+cWQJLz-56_88mrf0ttJX3W=0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Daniel Baluta <daniel.baluta@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:54223 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753295Ab1AZMfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 07:35:38 -0500
In-Reply-To: <AANLkTikSvf8bNK2_eHg+cWQJLz-56_88mrf0ttJX3W=0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Wed, 26 Jan 2011 14:23:44 +0200, Daniel Baluta wrote:
> Hi,
>
> On Wed, Jan 26, 2011 at 2:14 PM,  <denys@visp.net.lb> wrote:
>> I am running server (TCP accelerator), which is initiating more than 
>> 40K
>> connections.
>> Each instance of server bound to separate IP, and each of them 
>> handling
>> around 5-10K connections.
>> At moments, when i have excessive connect/disconnect events if i try 
>> to
>> establish connection even from IP is not used,
>> during bind() i am getting errno "Address already in use".
>> What can be the issue?
>> Will it help if i increase in kernel hardcoded limit from 64K TCP 
>> bind hash
>> entries to higher values?
>
> Please provide more information. What kernel version are you using?
> Are you  binding on a SO_REUSEADDR socket right?
 Latest stable, 2.6.37

 No, but trying with it now. At same time i think it is not correct, if 
 i try to bind to "unused" for any connections IP, and it will return 
 such error.
 It is not listening socket, it is outbound connection
 s = socket(...)
 memset(&name,0x0,sizeof(name));
 name.sin_family=AF_INET;
 name.sin_addr.s_addr=s_stx->src_ip;
 name.sin_port=0;
 bind()
 connect()

 Now i will try to put between socket and bind
 setsockopt(netsocket,SOL_SOCKET,SO_REUSEADDR,(void*)&tmpint,sizeof(tmpint));

 But IMHO it is not very correct for outgoing connections.
