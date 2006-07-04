From: Sam Vilain <sam@vilain.net>
Subject: Re: strict isolation of net interfaces
Date: Tue, 04 Jul 2006 15:00:22 +1200
Message-ID: <44A9D9C6.4060508@vilain.net>
References: <20060627225213.GB2612@MAIL.13thfloor.at> <1151449973.24103.51.camel@localhost.localdomain> <20060627234210.GA1598@ms2.inr.ac.ru> <m1mzbyj6ft.fsf@ebiederm.dsl.xmission.com> <20060628133640.GB5088@MAIL.13thfloor.at> <1151502803.5203.101.camel@jzny2> <44A44124.5010602@vilain.net> <44A450D1.2030405@fr.ibm.com> <20060630023947.GA24726@sergelap.austin.ibm.com> <44A49121.4050004@vilain.net> <20060703185350.A16826@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	Cedric Le Goater <clg@fr.ibm.com>, hadi@cyberus.ca,
	Herbert Poetzl <herbert@13thfloor.at>,
	Alexey Kuznetsov <alexey@sw.ru>, viro@ftp.linux.org.uk,
	devel@openvz.org, dev@sw.ru, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Ben Greear <greearb@candelatech.com>,
	Dave Hansen <haveblue@us.ibm.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751361AbWGDC7q@vger.kernel.org>
To: Andrey Savochkin <saw@swsoft.com>
In-Reply-To: <20060703185350.A16826@castle.nmd.msu.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrey Savochkin wrote:
>> Why special case loopback?
>>
>> Why not:
>>
>> host                  |  guest 0  |  guest 1  |  guest2
>> ----------------------+-----------+-----------+--------------
>>   |                   |           |           |
>>   |-> lo              |           |           |
>>   |                   |           |           |
>>   |-> vlo0  <---------+-> lo      |           |
>>   |                   |           |           |
>>   |-> vlo1  <---------+-----------+-----------+-> lo
>>   |                   |           |           |
>>   |-> vlo2   <--------+-----------+-> lo      |
>>   |                   |           |           |
>>   |-> eth0            |           |           |
>>   |                   |           |           |
>>   |-> veth0  <--------+-> eth0    |           |
>>   |                   |           |           |
>>   |-> veth1  <--------+-----------+-----------+-> eth0
>>   |                   |           |           |
>>   |-> veth2   <-------+-----------+-> eth0    |
>>     
>
> I still can't completely understand your direction of thoughts.
> Could you elaborate on IP address assignment in your diagram, please?  For
> example, guest0 wants 127.0.0.1 and 192.168.0.1 addresses on its lo
> interface, and 10.1.1.1 on its eth0 interface.
> Does this diagram assume any local IP addresses on v* interfaces in the
> "host"?
>   

Well, Eric already pointed out some pretty good reasons why this thread
should die.

The idea is that each "lo" interface would have the same set of
addresses. Which would make routing on the host confusing. Yet another
reason to kill this idea. Let's just make better tools instead.

Sam.

> And the second question.
> Are vlo0, veth0, etc. devices supposed to have hard_xmit routines?
>   
