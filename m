From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: 04 Jan 2005 22:12:08 -0500
Message-ID: <1104894728.1117.56.camel@jzny.localdomain>
References: <20050103125635.GB26856@postel.suug.ch>
	 <20050104223612.GN26856@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050104223612.GN26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-01-04 at 17:36, Thomas Graf wrote:

>  * TCF_EM_SIMPLE flag which marks an ematch config as simple, meaning
>    that the data consists of a u32 value.

This is 1 of 2 parts i think thats still an issue; otherwise looks very
good. 
Why do i need to signal something as simple? AND why does it have to be
32 bit type - what edge does that give you?
I should be able to specify a struct with two 32 bits and 
encap it in a TLV and the classifier can treat it the same way - it
knows the type and length - thats sufficient to create, destroy and
dump.
The other issue is still on the ematch/match interleaving i.e i should
be able to say something along the lines:

//simple slammer-worm or code-red ACL detector rule 
//using u32 classifier and ematches
(match ip protocol udp port 1434 AND
ematch packetlen minsize 404 maxsize 404) OR
(match ip protocol tcp http AND 
ematch urlscanner "*.ida") 
action ipt -j ULOG "Virus detected and dropped"
action drop

Not a very good example - but you can see how powerfull this is when you
can quickly use a string scanner such as the one you have as an ematch
while maintaining u32 as is. 

cheers,
jamal
