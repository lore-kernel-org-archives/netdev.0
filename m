From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Mon, 24 Jan 2011 10:27:55 -0800
Message-ID: <4D3DC4AB.1000207@hp.com>
References: <20110114063528.GB10957@verge.net.au>	<20110114065415.GA30300@redhat.com>	<20110116223728.GA6279@verge.net.au>	<20110117102655.GH23479@redhat.com> <4D35ECE2.4040901@hp.com>	<20110120083727.GA1807@verge.net.au>	<20110121095929.GE26070@redhat.com>	<20110121231149.GI2195@verge.net.au>	<20110122215742.GC5617@redhat.com>	<20110123063849.GB2673@verge.net.au> <20110123103902.GA28585@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>, Jesse Gross <jesse@nicira.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:14694 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945Ab1AXS2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 13:28:00 -0500
In-Reply-To: <20110123103902.GA28585@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> Just to block netperf you can send it SIGSTOP :)
> 

Clever :)  One could I suppose achieve the same result by making the remote 
receive socket buffer size smaller than the UDP message size and then not worry 
about having to learn the netserver's PID to send it the SIGSTOP.  I *think* the 
semantics will be substantially the same?  Both will be drops at the socket 
buffer, albeit for for different reasons.  The "too small socket buffer" version 
though doesn't require one remember to "wake" the netserver in time to have it 
send results back to netperf without netperf tossing-up an error and not 
reporting any statistics.

Also, netperf has a "no control connection" mode where you can, in effect cause 
it to send UDP datagrams out into the void - I put it there to allow folks to 
test against the likes of echo discard and chargen services but it may have a 
use here.  Requires that one specify the destination IP and port for the "data 
connection" explicitly via the test-specific options.  In that mode the only 
stats reported are those local to netperf rather than netserver.

happy benchmarking,

rick jones
