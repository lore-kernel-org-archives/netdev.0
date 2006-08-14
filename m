From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC][PATCH 0/4] VM deadlock prevention -v4
Date: Mon, 14 Aug 2006 08:21:27 -0400
Message-ID: <44E06AC7.6090301@redhat.com>
References: <20060812141415.30842.78695.sendpatchset@lappy> <33471.81.207.0.53.1155401489.squirrel@81.207.0.53> <1155404014.13508.72.camel@lappy> <47227.81.207.0.53.1155406611.squirrel@81.207.0.53> <1155408846.13508.115.camel@lappy> <44DFC707.7000404@google.com> <20060814052015.GB1335@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Phillips <phillips@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Indan Zupancic <indan@nul.nu>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752024AbWHNMVq@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060814052015.GB1335@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Sun, Aug 13, 2006 at 05:42:47PM -0700, Daniel Phillips (phillips@google.com) wrote:

>> As for sk_buff cow break, we need to look at which network paths do it
>> (netfilter obviously, probably others) and decide whether we just want
>> to declare that the feature breaks network block IO, or fix the feature
>> so it plays well with reserve accounting.
> 
> I would suggest to consider skb cow (cloning) as a must.

That should not be any problem, since skb's (including cowed ones)
are short lived anyway.  Allocating a little bit more memory is
fine when we have a guarantee that the memory will be freed again
shortly.

-- 
What is important?  What you want to be true, or what is true?
