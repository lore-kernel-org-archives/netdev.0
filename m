From: Ethan Sommer <sommere@ethanet.com>
Subject: Re: [Fwd: [ANNOUNCE] Layer-7 Filter for Linux QoS]
Date: Wed, 21 May 2003 18:26:12 -0500
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3ECC0B14.7020105@ethanet.com>
References: <Pine.LNX.4.40.0305220107460.29409-100000@phil.home.phil>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi <hadi@shell.cyberus.ca>,
	Martin Josefsson <gandalf@wlug.westbo.se>,
	"David S. Miller" <davem@redhat.com>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
In-reply-to: <Pine.LNX.4.40.0305220107460.29409-100000@phil.home.phil>
To: Philippe Biondi <biondi@cartel-securite.fr>
List-Id: netdev.vger.kernel.org

Philippe Biondi wrote:

>On Wed, 21 May 2003, Ethan Sommer wrote:
>
>  
>
>>Philippe Biondi wrote:
>>
>>    
>>
>>>regexp support was planned but not done yet. (if someone know where I can
>>>download more free time !).
>>>
>>>The implementation should not be that hard, once you have the compiler to
>>>transform the string describing the regexp to an automaton.
>>>
>>>Note that to respect the framework, you have to deal with multiple
>>>patterns (should not be that hard). If you have pat1 and pat2, searching
>>>for (pat1|pat2) is not sufficient because for each match, you have to
>>>point which pattern matched.
>>>
>>>
>>>      
>>>
>>We actually planned on doing that initially. You should note that if you
>>want to generate one automaton for multiple patterns, that is not a
>>regular language (and thus can not be represented by a FA or DFA.)  You
>>will have to try matching against the first pattern, then the next and
>>so on.
>>    
>>
>
>If P and Q are regexps, P|Q is a regexp, so you do can.
>So detection is clearly not a problem. But to fit in the libqsearch model,
>you have to know which of the parterns matched. This is theorically
>possible, but need a bit of work in comparison with using an
>off-the-shelf regexp compiler on (Pat1|Pat2|..|Patn).
>  
>
I take it back, it is regular (kinda) but you can't to it with a 
deterministic finite atomaton. If there is a cycle in pattern1, off of 
which pattern2 has a branch, then you would need to count how many times 
you have gone around the cycle to know where to jump to in pattern2 if 
it fails to match pattern1 (which you can't do, pumping lemma and all 
that.) If you use a non-determistic FA, you should be able to just go 
through each pattern until both crash or one matches and declare that 
the winner.

If your lib did that, it would work quite well for the layer-7 filter.

Ethan


