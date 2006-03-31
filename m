From: "Andrew Grover" <andy.grover@gmail.com>
Subject: Re: [PATCH 1/9] [I/OAT] DMA memcpy subsystem
Date: Fri, 31 Mar 2006 12:27:31 -0800
Message-ID: <c0a09e5c0603311227r210209c3v19d80386ab9fc168@mail.gmail.com>
References: <20060329225505.25585.30392.stgit@gitlost.site>
	 <c0a09e5c0603301036s4e9a63e5v476d89ff8ba37760@mail.gmail.com>
	 <351C5BDA-D7E3-4257-B07E-ABDDCF254954@kernel.crashing.org>
	 <200603311026.33391.netdev@axxeo.de>
	 <c0a09e5c0603311204k6b64842bm741d3e7726b39e77@mail.gmail.com>
	 <C46414E1-3A15-48CF-86F9-4D1D219DC1E7@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Ingo Oeser" <netdev@axxeo.de>,
	"Chris Leech" <christopher.leech@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751318AbWCaU1c@vger.kernel.org>
To: "Kumar Gala" <galak@kernel.crashing.org>
In-Reply-To: <C46414E1-3A15-48CF-86F9-4D1D219DC1E7@kernel.crashing.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/31/06, Kumar Gala <galak@kernel.crashing.org> wrote:
> > Currently the code updates these variables (kept per cpu) every time a
> > copy is queued. See include/linux/dmaengine.h.
>
> Might it be better to update when the transfer is done incase of an
> error?

The queueing function is really in the best position to do this. It
knows the size of each request. However in the cleanup/status check
routine, all we know is the last request completed -- we don't know
the completed requests' sizes.

The other reason is that the DMA engine should never throw an error.
If it does then something is very wrong, we print scary warnings, and
up-to-date stats are the least of our problems.

Regards -- Andy
