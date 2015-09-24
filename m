From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net 0/2] lwtunnel: make it really work, for IPv4
Date: Thu, 24 Sep 2015 10:35:11 +0200
Message-ID: <20150924103511.6fe80b6b@griffin>
References: <cover.1442936392.git.jbenc@redhat.com>
	<87zj0d92ba.fsf@x220.int.ebiederm.org>
	<20150923080957.GB29680@pox.localdomain>
	<87lhbx72j2.fsf@x220.int.ebiederm.org>
	<20150923162927.6d437a1f@griffin>
	<8761313ud5.fsf@x220.int.ebiederm.org>
	<20150923225456.74c5cd1d@griffin>
	<878u7w6dxh.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48279 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752507AbbIXIfP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 04:35:15 -0400
In-Reply-To: <878u7w6dxh.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Sep 2015 16:09:14 -0500, Eric W. Biederman wrote:
> *Blink* You were targeting net.git with a feature enhancement????
> I will just ignore that.

I do not. This is set is a minimal fix to make IP based lwtunnels with
tunnel information specified in a route working (for IPv4, anyway).
Note that lwtunnels and IP/UDP based lwtunnels is a new feature merged
for 4.3. This set fixes a flaw in that feature.

Eric, I'd like you to ask how do you propose to fix this problem in
net.git. So far, your proposals were:

1. Use a new ndo to "reverse" metadata dst. I can do that but all
   current users will just call iptunnel_metadata_reply. Seems to be
   superfluous but whatever.

2. Replace metadata_dst on ingress with a combination of cb and
   outer_*_header. This is certainly not suitable for net.git and won't
   solve the problem anyway.

Meanwhile, I'm going to resubmit patch 2 as a separate fix, as this is
kind of urgent. Having non working feature in a released kernel is sad
but only a temporary problem. Having non working uAPI in a released
kernel is a problem we'll have to deal with forever.

 Jiri

-- 
Jiri Benc
