From: Aidas Kasparas <a.kasparas@gmc.lt>
Subject: Re: [Ipsec-tools-devel] ipv4/ipv6 forwarding check
Date: Fri, 29 Oct 2004 10:05:39 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4181EBC3.3020507@gmc.lt>
References: <200410300506.i9U56Yse005815@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ipsec-tools-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Joy Latten <latten@austin.ibm.com>
In-Reply-To: <200410300506.i9U56Yse005815@faith.austin.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Joy,

	Need to have forward policies (which are not specified in RFC 2401 or 
any other ipsec related RFC I've read) was like a thunder from the blue 
sky to us. There is no way in setkey how to insert forward policies at 
the moment. Which of the following directions to solve this problem we 
have not decided yet:
	1) push kernel developers to have rfc2401 semantics in kernel;
	1a) have pfkey kernel part transform rfc2401 semantics into kernel 
semantics;
	2) have libpfkey generate extra policies transparently to the user;
	3) have tools (setkey and racoon) generate extra policies transparently 
to the user;
	4) extend setkey's syntax to make explicit forward policy management 
possible and write docs for all the admins to change policies.

	Personally I would like to have (1). This would make setups simpler. I 
believe, people with embeded applications would like very much to have 
(1) too (as extra policies => extra memory use will drive them mad). 
Yet, I have little hope this will happen :-//.

	Second least worst thing IMHO would be a combination of (2) and (4). 
Libpfkey functions have to be rewritten to generate extra forward 
policies, and current functions should be renamed as to provide view to 
real situation. Setkey should have a swith which tells to operate in 
rfc2401 compliant fashion (generating forward policies) or kernel mode 
(adding/removing/showing policies, including forward, as they are).

	Oppinions anyone?

	Meanwhile, I would like to recomend to abstain from upgrading to 
anything above 2.6.9.

Joy Latten wrote:
> I understand there has been discussion and code change 
> for checks with tunnel mode and forwarding packets. 
> In 2.6.9 with latest patches all my decapsulated tunnel mode 
> packets instead of being forwarded onto receiving subnet
> or dropped.
> How do I specify manually with setkey (syntax?), to forward
> decapsulated packets onto receiving subnet?
> 
> Thanks for any help.
> 
> Joy Latten

-- 
Aidas Kasparas
IT administrator
GM Consult Group, UAB
