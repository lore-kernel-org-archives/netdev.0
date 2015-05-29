From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: Possible issue in iproute2 package
Date: Fri, 29 May 2015 09:33:43 +0300
Message-ID: <20150529063343.GA12719@angus-think.wlc.globallogic.com>
References: <1432847547.19276.47.camel@jrguzman-mobl2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@osdl.org" <shemminger@osdl.org>
To: "Guzman Mosqueda, Jose R" <jose.r.guzman.mosqueda@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:34868 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752145AbbE2Geo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 02:34:44 -0400
Received: by lbbuc2 with SMTP id uc2so42315501lbb.2
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 23:34:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1432847547.19276.47.camel@jrguzman-mobl2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jose,

On Thu, May 28, 2015 at 09:12:15PM +0000, Guzman Mosqueda, Jose R wrote:
> 
> Hi all
> 
> I'm Jose Guzman from a security team at Intel.
> We're using iproute2 in a GNU-Linux project and I'm analyzing the code
> to try to find possible issues/gaps/risks.
> Since I'm not too familiar with the package yet I have a question about
> a particular piece of code that could result in a memory corruption:
> 
> Version: 4.0.0
> File: misc/ss.c
> Function: static void tcp_show_info(...)
> Line: ~1903
> Description: There is a memory allocation for a "s.cong_alg" variable:
> s.cong_alg = malloc(strlen(cong_attr + 1));
> The length is calculated about next position of the starting character.
> But next line there is a copy of the whole content:
> strcpy(s.cong_alg, cong_attr);
> I think there is a mistake and it should be something like:
> s.cong_alg = malloc(strlen(cong_attr) + 1);
I think strdup can be used here.
I will send a patch.

Thank You!
