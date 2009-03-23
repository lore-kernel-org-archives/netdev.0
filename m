From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: Use request_firmware()
Date: Mon, 23 Mar 2009 16:24:16 -0700
Message-ID: <1237850656.18617.34.camel@HP1>
References: <1237501747.4126.10.camel@deadeye.i.decadent.org.uk>
 <1237503884.16140.23.camel@HP1>
 <20090319232541.GA19262@wavehammer.waldi.eu.org>
 <20090320.155030.164080684.davem@davemloft.net>
 <1237844879.18617.20.camel@HP1>
 <20090323222915.GA29609@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Bastian Blank" <waldi@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1400 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751398AbZCWX3b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2009 19:29:31 -0400
In-Reply-To: <20090323222915.GA29609@wavehammer.waldi.eu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2009-03-23 at 15:29 -0700, Bastian Blank wrote:
> On Mon, Mar 23, 2009 at 02:47:59PM -0700, Michael Chan wrote:
> > I'd also like to add the version information to the bnx2_fw_file_entry
> > struct instead of embedding it in the file name.  It is more flexible
> > this way as each section can have different versions and can be updated
> > separately.  So it will look something like:
> > 
> > struct bnx2_fw_file_entry {
> > 	__be32 start_addr;
> > 	__be32 version;
> > 	struct bnx2_fw_file_section text;
> > 	struct bnx2_fw_file_section data;
> > 	struct bnx2_fw_file_section sbss;
> > 	struct bnx2_fw_file_section bss;
> > 	struct bnx2_fw_file_section rodata;
> > };
> 
> And how do you want to handle the compatibility? One firmware file have
> to work with many kernels, which was always described as impossible.
> 

I see your point.  May be I'll break up each firmware section into a
different file and the file name will be updated with each version.
This will allow different sections to be updated separately and older
kernels will still have access to the older firmware.


