From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] High Performance Packet Classifiction for tc framework
Date: 12 Aug 2003 11:41:46 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1060702906.1065.66.camel@jzny.localdomain>
References: <200307141045.40999.nf@hipac.org>
	 <1058328537.1797.24.camel@jzny.localdomain>  <3F16A0E5.1080007@hipac.org>
	 <1059934468.1103.41.camel@jzny.localdomain>  <3F2E5CD6.4030500@hipac.org>
	 <1060012260.1103.380.camel@jzny.localdomain>  <3F302E04.1090503@hipac.org>
	 <1060286331.1025.73.camel@jzny.localdomain>  <3F381B3E.6080807@hipac.org>
	 <1060657028.1028.79.camel@jzny.localdomain>  <3F390014.1080708@hipac.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: nf@hipac.org
In-Reply-To: <3F390014.1080708@hipac.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2003-08-12 at 10:56, Michael Bellion and Thomas Heinz wrote:
> Hi Jamal
> 
> Apart from the fact that the "pencil and paper" approach is not
> feasible for complex examples where there are no strict regularities
> in the rule set, you simply cannot avoid the implications when
> choosing a certain prefix length for the hash (as described in the
> previous posting). So probably in most cases even "pencil and paper"
> won't help.
> 

If you give me _sufficient time_ it should work ;->
Note, i am not defining sufficient time ;-> Its a different
approach,your approach - when you get it right- is the right way.

> > yes. But note the caveat i put above on knowing the input and being able
> > to manually use a pencil to map out the hash. Now automate the pencil
> > and paper and let some cpu analyse the traffic patterns as well as
> > adjust the hashes ... maybe a thesis for someone.
> 
> Yes, maybe someone should dig further but as long as the
> assumptions stay the same you have to live with the consequences
> stated in our last posting.
> 

If you have any students interested in a thesis let me know.

> > well, with the iptables scheme at least you need to know where to insert
> > the rules; so theres some manual labor involved there as well ;->
> > Out of curiosity with such a model how do you define a default rule?
> > In the prio model(and tc), you can have a default catchall rule in the
> > lowest priority, this way should higher prios fail this will catchall.
> 
> In theory the default rule has priority "infinity".
> In an implementation you can simply choose the priority of the default
> rule 1 + max{prio(r) | for all rules r}. So it's increased by 1 for
> every insert operation.
> 

And the reason you do this is because you dont know how many rules will
exist ahead of time. With static priorities you can set the default to
the max value.


> >>Each rule can only have one action or return "value"
> >>attached to it so if we want to use embedded classifiers
> >>(as matches) their classid (= action) must be ignored.
> > 
> > you want the "continue" action essentially.
> 
> Sorry but we don't seem to get your point here.
> How is the "continue" action related to having multiple
> embedded classifiers in a rule which essentially provides
> 1 single action?
> 

tc add <filter1 desc> continue <filter2 desc> continue <filter3 desc>
accept

- filter1-3 are derived from different classifiers. the accept at the
end is doable if you use the tc extensions i am working on. 

on the setclassid stuff i will ping Alexey and Davem on it - it could be
a 2.7 action item. For now, you will have to live with it. BTW, have you
tried to leave out defining the classid definition?;-> policy gets
accepted fine, i think its a bug but it could be a feature - dont have
time to look at it right now.

cheers,
jamal
