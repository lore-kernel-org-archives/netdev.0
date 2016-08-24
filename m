From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [ethtool PATCH v4 0/4]  Add support for QSFP+/QSFP28 Diagnostics
 and 25G/50G/100G      port speeds
Date: Wed, 24 Aug 2016 16:01:23 -0400
Message-ID: <20160824200122.GC20493@tuxdriver.com>
References: <1471959033-1053-1-git-send-email-vidya@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, decot@googlers.com,
        bkenward@solarflare.com, daniel@iogearbox.net, galp@mellanox.com,
        roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
        dustin@cumulusnetworks.com, ben@decadent.org.uk
To: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43646 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755430AbcHXU4x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 16:56:53 -0400
Content-Disposition: inline
In-Reply-To: <1471959033-1053-1-git-send-email-vidya@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have pushed this series. I did modify patches 3 and 4 a bit,
to properly update Makefile.am in order to keep "make distcheck"
from failing -- please be more careful in the future.

John

P.S. I have not yet tagged this as an official release, so please test!

On Tue, Aug 23, 2016 at 06:30:29AM -0700, Vidya Sagar Ravipati wrote:
> From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
> 
> This patch seryies provides following support
> a) Reorganized fields based out of SFF-8024 fields i.e. Identifier/
>    Encoding/Connector types which are common across SFP/SFP+ (SFF-8472)
>    and QSFP+/QSFP28 (SFF-8436/SFF-8636) modules into sff-common files.
> b) Support for diagnostics information for QSFP Plus/QSFP28 modules
>    based on SFF-8436/SFF-8636
> c) Supporting 25G/50G/100G speeds in supported/advertising fields
> d) Tested across various QSFP+/QSFP28 Copper/Optical modules
> 
> Standards for QSFP+/QSFP28
> a) QSFP+/QSFP28 - SFF 8636 Rev 2.7 dated January 26,2016
> b) SFF-8024 Rev 4.0 dated May 31, 2016
> 
> v4:
>   Sync ethtool-copy.h to kernel commit 89da45b8b5b2187734a11038b8593714f964ffd1
>   which includes support for 50G base SR2
> 
> v3:
>  Review comments from Ben Hutchings:
>    Make sff diags structure common across sfpdiag.c and
>    qsfp.c and use common function to print common threshold
>    values.
>  Review comments from Rami Rosen:
>    Cleanup description messages.
> 
> v2:
>   Included support for 25G/50G/100G speeds in supported/
>   advertised speed modes
>   Review comments from Ben Hutchings:
>     Split the sff-8024 reorganzing patch and QSFP+/QSFP28
>     patch
>     Fixed all checkpatch warnings (except couple of over 80 character)
> 
> v1:
>   Support for SFF-8636 Rev 2.7
>   Review comments from Ben Hutchings:
>    Updating copyright holders information for QSFP
>    Reusing the common functions and macros across sfpid and qsfp
> 
> Vidya Sagar Ravipati (4):
>   ethtool-copy.h:sync with net
>   ethtool:Reorganizing  SFF-8024 fields for SFP/QSFP
>   ethtool:QSFP Plus/QSFP28 Diagnostics Information Support
>   ethtool: Enhancing link mode bits to support 25G/50G/100G
> 
>  Makefile.am    |   2 +-
>  ethtool-copy.h |  18 +-
>  ethtool.c      |  35 +++
>  internal.h     |   3 +
>  qsfp.c         | 788 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  qsfp.h         | 595 +++++++++++++++++++++++++++++++++++++++++++
>  sff-common.c   | 304 ++++++++++++++++++++++
>  sff-common.h   | 189 ++++++++++++++
>  sfpdiag.c      | 105 +-------
>  sfpid.c        | 103 +-------
>  10 files changed, 1945 insertions(+), 197 deletions(-)
>  create mode 100644 qsfp.c
>  create mode 100644 qsfp.h
>  create mode 100644 sff-common.c
>  create mode 100644 sff-common.h
> 
> -- 
> 2.1.4
> 
> 

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
