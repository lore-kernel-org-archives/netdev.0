From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [ANNOUNCE] Release of nf-HiPAC 0.9.0
Date: Thu, 06 Oct 2005 11:09:25 -0400
Message-ID: <43453E25.9020903@tmr.com>
References: <200509260445.46740.mbellion@hipac.org> <4337DA7C.2000804@cs.aau.dk> <200509261638.12731.mbellion@hipac.org>
Mime-Version: 1.0
Content-Type: multipart/alternative;
 boundary="------------040706060300040508090100"
Cc: Emmanuel Fleury <fleury@cs.aau.dk>, linux-kernel@vger.kernel.org,
        linux-net@vger.kernel.org, netdev@oss.sgi.com, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Bellion <mbellion@hipac.org>
In-Reply-To: <200509261638.12731.mbellion@hipac.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040706060300040508090100
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Michael Bellion wrote:

>Hi
>
>  
>
>>I'm still not convinced by your approach. :-/
>>    
>>
>
>You really should have a closer look at nf-HiPAC so that you know what you are 
>talking about!
>
>Your Compact Filter takes a completely different approach than nf-HiPAC to 
>build the data structure used in the kernel for the packet classification 
>lookup.
>
>Your Compact Filter uses a static compiler in user space. That compiler 
>transforms the rule set into boolean expressions and than uses operations 
>from predicate logic to optimize the rule set.
>This has the big drawback that whenever only a single rule changes you have to 
>recompile the complete lookup data structure. So this approach is clearly not 
>suitable for scenarios depending on dynamic rule sets.
>
>nf-HiPAC uses a completely different approach to build the lookup data 
>structure in the kernel. It is based on geometry.
>This approach allows completely dynamic updates. During an update of the rules 
>only the required changes of the lookup data structure are made. The data 
>structure is NOT rebuild from scratch. This guarantees that the packet 
>processing is only affected to the least possible amount during updates.
>
>Although nf-HiPAC and Compact Filter use completely different approaches and 
>algorithms to build the lookup data structure it is important that you 
>understand the following:
>nf-HiPAC and Compact filter end up with a very very similar lookup data 
>structure in the kernel.
>
>
>  
>
>>These experiments have to be updated but can you comment on this:
>>http://www.cs.aau.dk/~mixxel/cf/experiments.html
>>    
>>
>
>The current version of the algorithm used in nf-HiPAC does not optimize 
>certain aspects of the lookup data structure in order to increase the speed 
>of dynamic rule set updates.
>This means that the lookup data structure is larger than it really needs to be 
>because it contains some unnecessary redundancy.
>This explains your test results.
>Compact Filter and nf-HiPAC perform the same when they are both able to keep 
>their lookup data structure in the CPU caches and when they are both not able 
>to do so anymore.
>Compact Filter is currently able to perform better in the area where it is 
>able to keep its data structure still in the caches while nf-HiPAC is not 
>able to do so anymore.
>  
>

It would seem, looking at the provided results and author's comments, 
that the following are true:
  - for small static rulesets there is little difference, my 200-600 
rules run fine in either
  - for very large rulesets cf will currently perform better (if this is 
due to cache effects, may be less
    evident, since the server runs an application rather than being a 
dedicated network device).
  - cf can't do large dynamic rulesets, compile time > change interval
  - the iptables results don't represent server use with persistent 
sockets, like mail/usenet, in which
    most (~95%) packets match the first rule in INPUT (ESTABLISHED -> 
ACCEPT) and the complexity is
    in processing TCP/SYN packets and forwarding rules.

Also: none of the results I've seen show the effect of many tracked 
sockets, the performance of one stream pushing a lot of packets is not 
the same as the same bitrate coming from 500-5k source IPs, at least if 
you use the INPUT rule noted above.

>Most aspects of your performance tests are quite nice (e.g. the generating the 
>traffic by replaying a packet header trace).
>But your performance tests have a serious flaw:
>You construct your rule set by creating one rule for each entry in your packet 
>header trace. This results in an completely artificial rule set that creates 
>a lot of redundancy in the nf-HiPAC lookup data structure making it much 
>larger than the Compact Filter data structure.
>
>You have to understand that with real world rule sets the size of the computed 
>lookup data structure will not be much different for Compact Filter and 
>nf-HiPAC. This means that when you use real world rule sets there shouldn't 
>be any noticeable difference in lookup performance betweeen Compact Filter 
>and nf-HiPAC.
>
>-----------------
>
>I am currently working on a new improved version of the algorithm used in 
>nf-HiPAC. The new algorithmic core will reduce memory usage while at the same 
>time improving the running time of insert and delete operations. The lookup 
>performance will be improved too, especially for bigger rulesets. The 
>concepts and the design are already developed, but the implementation is 
>still in its early stages.
>
>The new algorithmic core will make sure that the lookup data structure in the 
>kernel is always fully optimized while at the same time allowing very fast 
>dynamic updates.
>
>At that point Compact Filter will not be able to win in any performance test 
>against  nf-HiPAC anymore, simply because there is no way to optimize the 
>lookup data structure any further.
>
The nf-HiPAC advantage seems to be in applications with moderate to 
large dynamic rulesets, in that it allows a lot of changes quickly. 
Don't give that up for throughput, the idea of being able to do 5-7 
changes/sec on a 500-2k ruleset is exciting, and in some cases vital.

Thanks to everyone working on improvements.

-- 
bill davidsen <davidsen@tmr.com>
  CTO TMR Associates, Inc
  Doing interesting things with small computers since 1979


--------------040706060300040508090100
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: 7bit

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html;charset=ISO-8859-1" http-equiv="Content-Type">
  <title></title>
</head>
<body bgcolor="#ffffff" text="#000000">
Michael Bellion wrote:
<blockquote cite="mid200509261638.12731.mbellion@hipac.org" type="cite">
  <pre wrap="">Hi

  </pre>
  <blockquote type="cite">
    <pre wrap="">I'm still not convinced by your approach. :-/
    </pre>
  </blockquote>
  <pre wrap=""><!---->
You really should have a closer look at nf-HiPAC so that you know what you are 
talking about!

Your Compact Filter takes a completely different approach than nf-HiPAC to 
build the data structure used in the kernel for the packet classification 
lookup.

Your Compact Filter uses a static compiler in user space. That compiler 
transforms the rule set into boolean expressions and than uses operations 
from predicate logic to optimize the rule set.
This has the big drawback that whenever only a single rule changes you have to 
recompile the complete lookup data structure. So this approach is clearly not 
suitable for scenarios depending on dynamic rule sets.

nf-HiPAC uses a completely different approach to build the lookup data 
structure in the kernel. It is based on geometry.
This approach allows completely dynamic updates. During an update of the rules 
only the required changes of the lookup data structure are made. The data 
structure is NOT rebuild from scratch. This guarantees that the packet 
processing is only affected to the least possible amount during updates.

Although nf-HiPAC and Compact Filter use completely different approaches and 
algorithms to build the lookup data structure it is important that you 
understand the following:
nf-HiPAC and Compact filter end up with a very very similar lookup data 
structure in the kernel.


  </pre>
  <blockquote type="cite">
    <pre wrap="">These experiments have to be updated but can you comment on this:
<a class="moz-txt-link-freetext" href="http://www.cs.aau.dk/~mixxel/cf/experiments.html">http://www.cs.aau.dk/~mixxel/cf/experiments.html</a>
    </pre>
  </blockquote>
  <pre wrap=""><!---->
The current version of the algorithm used in nf-HiPAC does not optimize 
certain aspects of the lookup data structure in order to increase the speed 
of dynamic rule set updates.
This means that the lookup data structure is larger than it really needs to be 
because it contains some unnecessary redundancy.
This explains your test results.
Compact Filter and nf-HiPAC perform the same when they are both able to keep 
their lookup data structure in the CPU caches and when they are both not able 
to do so anymore.
Compact Filter is currently able to perform better in the area where it is 
able to keep its data structure still in the caches while nf-HiPAC is not 
able to do so anymore.
  </pre>
</blockquote>
<br>
It would seem, looking at the provided results and author's comments,
that the following are true:<br>
&nbsp; - for small static rulesets there is little difference, my 200-600
rules run fine in either<br>
&nbsp; - for very large rulesets cf will currently perform better (if this
is due to cache effects, may be less<br>
&nbsp;&nbsp;&nbsp; evident, since the server runs an application rather than being a
dedicated network device).<br>
&nbsp; - cf can't do large dynamic rulesets, compile time &gt; change
interval<br>
&nbsp; - the iptables results don't represent server use with persistent
sockets, like mail/usenet, in which<br>
&nbsp;&nbsp;&nbsp; most (~95%) packets match the first rule in INPUT (ESTABLISHED
-&gt; ACCEPT) and the complexity is<br>
&nbsp;&nbsp;&nbsp; in processing TCP/SYN packets and forwarding rules.<br>
<br>
Also: none of the results I've seen show the effect of many tracked
sockets, the performance of one stream pushing a lot of packets is not
the same as the same bitrate coming from 500-5k source IPs, at least if
you use the INPUT rule noted above.<br>
<blockquote cite="mid200509261638.12731.mbellion@hipac.org" type="cite">
  <pre wrap="">
Most aspects of your performance tests are quite nice (e.g. the generating the 
traffic by replaying a packet header trace).
But your performance tests have a serious flaw:
You construct your rule set by creating one rule for each entry in your packet 
header trace. This results in an completely artificial rule set that creates 
a lot of redundancy in the nf-HiPAC lookup data structure making it much 
larger than the Compact Filter data structure.

You have to understand that with real world rule sets the size of the computed 
lookup data structure will not be much different for Compact Filter and 
nf-HiPAC. This means that when you use real world rule sets there shouldn't 
be any noticeable difference in lookup performance betweeen Compact Filter 
and nf-HiPAC.

-----------------

I am currently working on a new improved version of the algorithm used in 
nf-HiPAC. The new algorithmic core will reduce memory usage while at the same 
time improving the running time of insert and delete operations. The lookup 
performance will be improved too, especially for bigger rulesets. The 
concepts and the design are already developed, but the implementation is 
still in its early stages.

The new algorithmic core will make sure that the lookup data structure in the 
kernel is always fully optimized while at the same time allowing very fast 
dynamic updates.

At that point Compact Filter will not be able to win in any performance test 
against  nf-HiPAC anymore, simply because there is no way to optimize the 
lookup data structure any further.</pre>
</blockquote>
The nf-HiPAC advantage seems to be in applications with moderate to
large dynamic rulesets, in that it allows a lot of changes quickly.
Don't give that up for throughput, the idea of being able to do 5-7
changes/sec on a 500-2k ruleset is exciting, and in some cases vital.<br>
<br>
Thanks to everyone working on improvements.<br>
<br>
<pre class="moz-signature" cols="72">-- 
bill davidsen <a class="moz-txt-link-rfc2396E" href="mailto:davidsen@tmr.com">&lt;davidsen@tmr.com&gt;</a>
  CTO TMR Associates, Inc
  Doing interesting things with small computers since 1979
</pre>
</body>
</html>

--------------040706060300040508090100--
